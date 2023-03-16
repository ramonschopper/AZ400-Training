// Part of JWT validation
/*
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Primitives;
using System.Threading.Tasks;
using System;
/// <summary>
/// Singleton class handler of events related to JWT authentication
/// </summary>
public class AuthEventsHandler : JwtBearerEvents
{
    private AuthEventsHandler() => OnMessageReceived = MessageReceivedHandler;
    public static AuthEventsHandler Instance { get; } = new AuthEventsHandler();

    private Task MessageReceivedHandler(MessageReceivedContext context)
    {
        if (context.Request.Headers.TryGetValue("Cf-Access-Jwt-Assertion", out StringValues headerValue))
        {
            string token = headerValue;
            if (!string.IsNullOrEmpty(token))
            {
                context.Token = token;
            }
            else
            {
                Console.WriteLine("No token found in the header");
                context.NoResult();
            }
        }
        else
        {
            Console.WriteLine("Header not found");
            context.NoResult();
        }
        return Task.CompletedTask;
    }
}
*/