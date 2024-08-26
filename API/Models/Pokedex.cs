using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Pokedex
    {
        [Key]
        public string Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; }

        [StringLength(50)]
        public string? Type { get; set; }

        [StringLength(50)]
        public string? Art { get; set; }

        public int? Hp { get; set; }
        public int? Attack { get; set; }
        public int? Defense { get; set; }
        public int? Speed { get; set; }
        public int? Weight { get; set; }
        public int? Height { get; set; }

        [Column(TypeName = "text")]
        public string? Description { get; set; }

        [StringLength(255)]
        public string? ImageUrl { get; set; }
    }
}
