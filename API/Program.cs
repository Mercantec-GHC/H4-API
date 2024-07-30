using System;
using System.Text;
using API.Context;
using API.Service;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.
            builder.Services.AddHttpClient();
            builder.Services.AddControllers();

            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // Add CORS services and define a global policy
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAnyOrigin", builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyMethod()
                           .AllowAnyHeader();
                });
            });

            IConfiguration Configuration = builder.Configuration;

            // Retrieve the connection string from configuration or environment variables
            string connectionString = Configuration.GetConnectionString("DefaultConnection")
                                      ?? Environment.GetEnvironmentVariable("CONNECTION_STRINGS_DEFAULT_CONNECTION");

            builder.Services.AddDbContext<AppDBContext>(options =>
                options.UseNpgsql(connectionString));

            // Retrieve JWT settings from configuration or environment variables
            var jwtKey = Configuration["JwtSettings:Key"] ?? Environment.GetEnvironmentVariable("JWT_SETTINGS_KEY");
            var jwtIssuer = Configuration["JwtSettings:Issuer"] ?? Environment.GetEnvironmentVariable("JWT_SETTINGS_ISSUER");
            var jwtAudience = Configuration["JwtSettings:Audience"] ?? Environment.GetEnvironmentVariable("JWT_SETTINGS_AUDIENCE");

            Console.WriteLine("JWT-Key: " + jwtKey);
            Console.WriteLine("JWT-Issuer: " + jwtIssuer);
            Console.WriteLine("JWT-Audience: " + jwtAudience);

            // Check if critical JWT settings are missing
            if (string.IsNullOrEmpty(jwtKey) || string.IsNullOrEmpty(jwtIssuer) || string.IsNullOrEmpty(jwtAudience))
            {
                throw new InvalidOperationException("JWT settings are not configured properly.");
            }

            // Configure JWT Authentication
            builder.Services.AddAuthentication(x =>
            {
                x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(x =>
            {
                x.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = jwtIssuer,
                    ValidAudience = jwtAudience,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true
                };
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseHttpsRedirection();

            // Apply CORS policy globally
            app.UseCors("AllowAnyOrigin");

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}
