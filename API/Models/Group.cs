namespace API.Models
{
    public class Group
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public ICollection<UserGroup> UserGroups { get; set; }
    }
    public class GroupDTO
    {
        public string Id { get; set; }
        public string Name { get; set; }
    }

    public class UserGroup
    {
        public string UserId { get; set; }
        public User User { get; set; }
        public string GroupId { get; set; }
        public Group Group { get; set; }
    }

    public class UserGroupDTO
    {
        public string UserId { get; set; }
        public string GroupId { get; set; }
    }
    
}
