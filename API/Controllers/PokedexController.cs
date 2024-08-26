using API.Context;
using API.Service;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Threading.Tasks;
using API.Models;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PokedexController : ControllerBase
    {
        private readonly string _accessKey;
        private readonly string _secretKey;
        private readonly AppDBContext _context;
        private readonly IConfiguration _configuration;
        private readonly R2Service _r2Service;

        public PokedexController(AppDBContext context, IConfiguration configuration, AppConfiguration config)
        {
            _context = context;
            _configuration = configuration;
            _accessKey = config.AccessKey;
            _secretKey = config.SecretKey;
            _r2Service = new R2Service(_accessKey, _secretKey);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPokedexEntry(int id)
        {
            var entry = await _context.Pokedex.FindAsync(id);

            if (entry == null)
            {
                return NotFound();
            }

            return Ok(entry);
        }

        [HttpPost]
        public async Task<IActionResult> PostPokedexEntry([FromForm] IFormFile file, [FromForm] string name, [FromForm] string type, [FromForm] string art, [FromForm] int? hp, [FromForm] int? attack, [FromForm] int? defense, [FromForm] int? speed, [FromForm] int? weight, [FromForm] int? height, [FromForm] string description)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest("No file uploaded.");
            }

            string imageUrl;
            try
            {
                using (var fileStream = file.OpenReadStream())
                {
                    var fileName = Path.GetFileName(file.FileName);
                    imageUrl = await _r2Service.UploadToR2(fileStream, fileName);
                }
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, $"Error uploading file: {ex.Message}");
            }

            var pokedexEntry = new Pokedex
            {
                Name = name,
                Type = type,
                Art = art,
                Hp = hp,
                Attack = attack,
                Defense = defense,
                Speed = speed,
                Weight = weight,
                Height = height,
                Description = description,
                ImageUrl = imageUrl
            };

            _context.Pokedex.Add(pokedexEntry);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPokedexEntry), new { id = pokedexEntry.Id }, pokedexEntry);
        }
    }
}
