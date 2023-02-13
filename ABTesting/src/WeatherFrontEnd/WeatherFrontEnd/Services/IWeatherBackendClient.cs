using Refit;

namespace WeatherFrontEnd.Services
{
    public interface IWeatherBackendClient
    {
        [Get("/WeatherForecast")]
        Task<List<WeatherForecast>> GetForecasts();
    }
}
