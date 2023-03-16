using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.IdentityModel.Tokens;
using System.Net.Http;

var builder = WebApplication.CreateBuilder(args);

// Part of JWT validation
/*
var cfAccountName = builder.Configuration["CloudflareAccountName"];
var cfIssuer = builder.Configuration["CloudflareIssuer"];
var cfAudience = builder.Configuration["CloudflareAudience"];
var signingKeyUri = $"https://{cfAccountName}.cloudflareaccess.com/cdn-cgi/access/certs";

HttpClient client = new HttpClient();
var response = client.GetAsync(signingKeyUri).Result;
var jwksString = response.Content.ReadAsStringAsync().Result;
var jwkset = new JsonWebKeySet(jwksString);
var signingKeys = jwkset.GetSigningKeys();
*/

builder.Services.AddRazorPages();
builder.Host.ConfigureServices(services =>
{
    services.AddControllersWithViews();

    // Part of JWT validation
    /*
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(o =>
    {
        o.IncludeErrorDetails = true;
        o.Events = AuthEventsHandler.Instance;
        o.TokenValidationParameters = new TokenValidationParameters()
        {
            ValidateIssuerSigningKey = true,
            ValidIssuer = cfIssuer,
            ValidAudience = cfAudience,
            IssuerSigningKeys = signingKeys
        };
    });
    */
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllerRoute(
        name: "default",
        pattern: "{controller=Home}/{action=Index}/{id?}");
});
app.Run();