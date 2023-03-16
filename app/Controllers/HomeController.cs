using BooksSample.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace BooksSample.Controllers
{
    internal class Token
    {
        [JsonProperty("access_token")]
        public string AccessToken { get; set; }

        [JsonProperty("token_type")]
        public string TokenType { get; set; }

        [JsonProperty("expires_in")]
        public int ExpiresIn { get; set; }

        [JsonProperty("refresh_token")]
        public string RefreshToken { get; set; }
    }

    public class OData
    {
        [JsonProperty("odata.metadata")]
        public string Metadata { get; set; }
        public List<Book> Value { get; set; }
    }

    // Part of JWT Validation
    //[Authorize]
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult About()
        {
            return View();
        }

        [HttpPost]
        public async Task<ActionResult> Index(SearchData model)
        {
            try
            {
                // Ensure the search string is valid.
                if (model.searchText == null)
                {
                    model.searchText = "";
                }

                // Make the Azure Cognitive Search call.
                await RunQueryAsync(model).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                return View("Error", new ErrorViewModel { RequestId = "1", Message = ex.Message });
            }

            return View(model);
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        private static IConfigurationBuilder _builder;
        private static IConfigurationRoot _configuration;
        private static string searchServiceUri;
        private static string appClientId;
        private static string appSecret;
        private static string tenantId;

        private static void InitSearch()
        {
            // Create a configuration using the appsettings file.
            _builder = new ConfigurationBuilder().AddJsonFile("appsettings.json").AddEnvironmentVariables();
            _configuration = _builder.Build();

            // Pull the values from the App Settings (file locally or App Service).
            searchServiceUri = _configuration["SearchServiceUri"];
            appClientId = _configuration["AppObjectId"];
            appSecret = _configuration["AppSecret"];
            tenantId = _configuration["TenantId"];
        }

        private static async Task<Token> GetToken(HttpClient client)
        {
            string baseAddress = String.Format(@"https://login.microsoftonline.com/{0}/oauth2/token", tenantId);
            
            string grant_type = "client_credentials";
            string resource = "https://search.azure.com/";

            var form = new Dictionary<string, string>
                {
                    {"grant_type", grant_type},
                    {"resource", resource},
                    {"client_id", appClientId},
                    {"client_secret", appSecret},
                };
            HttpResponseMessage tokenResponse = await client.PostAsync(baseAddress, new FormUrlEncodedContent(form));
            var jsonContent = await tokenResponse.Content.ReadAsStringAsync();
            Token tok = JsonConvert.DeserializeObject<Token>(jsonContent);
            return tok;
        }

        private static async Task<List<Book>> GetSearchResults(HttpClient client, string token, string searchText)
        {
            string baseAddress = String.Format("{0}/indexes/{1}/docs?api-version=2021-04-30-Preview&search={2}", searchServiceUri, "good-books", searchText);

            using (var requestMessage =
            new HttpRequestMessage(HttpMethod.Get, baseAddress))
            {
                requestMessage.Headers.Authorization =
                    new AuthenticationHeaderValue("Bearer", token);

                HttpResponseMessage tokenResponse = await client.SendAsync(requestMessage);
                if (tokenResponse.StatusCode == HttpStatusCode.OK)
                {
                    var jsonContent = await tokenResponse.Content.ReadAsStringAsync();
                    //object booksObj = JsonConvert.DeserializeObject(jsonContent);
                    var odata = JsonConvert.DeserializeObject<OData>(jsonContent);
                    
                    List<Book> books = odata.Value;
                    
                    return books;
                }
                return null;
            }
        }

        private async Task<ActionResult> RunQueryAsync(SearchData model)
        {
            InitSearch();

            // get the token using App Registration client secret from App Settings
            HttpClient client = new HttpClient();
            Token t = await GetToken(client);

            // search books using search text
            client = new HttpClient();
            model.bookList = await GetSearchResults(client, t.AccessToken, model.searchText);

            // Display the results.
            return View("Index", model);
        }
    }
}
