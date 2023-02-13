using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.FeatureManagement;

var builder = WebApplication.CreateBuilder(args);

string config = builder.Configuration.GetValue<string>("AzureAppConfig");
builder.Configuration.AddAzureAppConfiguration(options =>
    options
        .Connect(config)
            .UseFeatureFlags(featureFlagOptions => featureFlagOptions.Label = builder.Configuration.GetValue<string>("RevisionLabel")));

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddFeatureManagement();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

public enum MyFeatureFlags
{
    Beta
}