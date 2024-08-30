﻿using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class Common
    {
        [Key]
        public string Id { get; set; } // Kan erstattes med "int Id"
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
