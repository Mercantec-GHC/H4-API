namespace API.Models
{
    public class ActivityLog
    {
        public string Id { get; set; }
        public DateTime Date { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; } 
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string Type { get; set; } 
        public string UserId { get; set; }
        public User User { get; set; }
    }

    public class ActivityLogDtO
    {
        public string Id { get; set; }
        public DateTime Date { get; set; }
        public int Steps { get; set; }
        public double Distance { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string Type { get; set; }
        public string UserId { get; set; }
    }
}
