using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using System.Net;

namespace WeatherApi.IntegrationTests
{
    public class WeatherForecastControllerShould : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly WebApplicationFactory<Program> _factory;

        public WeatherForecastControllerShould(WebApplicationFactory<Program> factory)
        {
            _factory=factory;
        }

        [Fact]
        public async Task ReturnOkWhenCallingGet()
        {
            // Arrange
            var client = _factory.CreateClient();

            // Act
            var response = await client.GetAsync(Environment.GetEnvironmentVariable("BLUE_SLOT_URL"));

            // Assert
            Assert.Equal((HttpStatusCode)StatusCodes.Status200OK, response.StatusCode);
        }
    }
}