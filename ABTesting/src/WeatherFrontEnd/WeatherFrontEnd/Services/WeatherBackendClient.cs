using Refit;

namespace WeatherFrontEnd.Services
{
    public class WeatherBackendClient : IWeatherBackendClient
    {
        IHttpClientFactory _httpClientFactory;

        public WeatherBackendClient(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory=httpClientFactory;
        }

        public async Task<List<WeatherForecast>> GetForecasts()
        {
            var client = _httpClientFactory.CreateClient("Weather");
            return await RestService.For<IWeatherBackendClient>(client).GetForecasts();
        }
    }
}
