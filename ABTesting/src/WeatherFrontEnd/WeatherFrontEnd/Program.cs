using WeatherFrontEnd.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddHttpClient("Weather", (httpClient) => httpClient.BaseAddress = new Uri(builder.Configuration.GetValue<string>("WeatherApi")));
builder.Services.AddSingleton<IWeatherBackendClient, WeatherBackendClient>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
