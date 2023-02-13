using Microsoft.AspNetCore.Mvc;
using Microsoft.FeatureManagement;

namespace FrontEnd.Controllers
{
    public class BetaController : Controller
    {
        private readonly IFeatureManager _featureManager;

        public BetaController(IFeatureManager featureManager)
        {
            _featureManager=featureManager;
        }

        public IActionResult Index()
        {
            return View();
        }
    }
}
