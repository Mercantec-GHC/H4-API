using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using API.Context;
using API.Models;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserGroupsController : ControllerBase
    {
        private readonly AppDBContext _context;

        public UserGroupsController(AppDBContext context)
        {
            _context = context;
        }

        // GET: api/UserGroups
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserGroup>>> GetUserGroups()
        {
            return await _context.UserGroups.ToListAsync();
        }

        // GET: api/UserGroups/5
        [HttpGet("{id}")]
        public async Task<ActionResult<UserGroup>> GetUserGroup(string id)
        {
            var userGroup = await _context.UserGroups.FindAsync(id);

            if (userGroup == null)
            {
                return NotFound();
            }

            return userGroup;
        }

        // PUT: api/UserGroups/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUserGroup(string id, UserGroup userGroup)
        {
            if (id != userGroup.UserId)
            {
                return BadRequest();
            }

            _context.Entry(userGroup).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                    throw;
            }

            return NoContent();
        }

        // POST: api/UserGroups
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost("JoinGroup")]
        public async Task<ActionResult<UserGroupDtO>> PostUserGroup(UserGroupDtO userGroupDtO)
        {
            // Map DTO to Entity
            var userGroup = new UserGroup
            {
                UserId = userGroupDtO.UserId,
                GroupId = userGroupDtO.GroupId
            };

            // Add the entity to the context
            _context.UserGroups.Add(userGroup);

            try
            {
                // Save changes to the database
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // Check if the UserGroup already exists
                if (UserGroupExists(userGroup.UserId, userGroup.GroupId))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            // Return the DTO with the created status
            return Ok("User added to group");
        }


        // DELETE: api/UserGroups/LeaveGroup
        [HttpDelete("LeaveGroup")]
        public async Task<IActionResult> LeaveGroup(UserGroupDtO userGroupDtO)
        {
            var userGroup = await _context.UserGroups
                .FirstOrDefaultAsync(ug => ug.UserId == userGroupDtO.UserId && ug.GroupId == userGroupDtO.GroupId);

            if (userGroup == null)
            {
                return NotFound();
            }

            _context.UserGroups.Remove(userGroup);
            await _context.SaveChangesAsync();

            return Ok("User removed from group");
        }


        private bool UserGroupExists(string userId, string groupId)
        {
            return _context.UserGroups.Any(ug => ug.UserId == userId && ug.GroupId == groupId);
        }

    }
}
