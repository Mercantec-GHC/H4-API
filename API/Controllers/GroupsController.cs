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
    public class GroupsController : ControllerBase
    {
        private readonly AppDBContext _context;

        public GroupsController(AppDBContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<GroupDtO>>> GetGroups()
        {
            
            var groups = await _context.Groups
                .Include(g => g.UserGroups) //Join on UserGroups
                .ThenInclude(ug => ug.User) //Join on User from UserGroups ug
                .ToListAsync();

            var groupDTOs = groups.Select(g => new GroupDtO
            {
                Id = g.Id,
                Name = g.Name,
                Members = g.UserGroups.Select(ug => ug.User.Username).ToList() 
            }).ToList();

            return groupDTOs;
        }


        // GET: api/Groups/5
        [HttpGet("{id}")]
        public async Task<ActionResult<GroupDtO>> GetGroup(string id)
        {
            var group = await _context.Groups
                .Include(g => g.UserGroups)
                .ThenInclude(ug => ug.User)  
                .SingleOrDefaultAsync(g => g.Id == id); 

            if (group == null)
            {
                return NotFound();
            }

            // Create a DTO from the Group
            var groupDTO = new GroupDtO
            {
                Id = group.Id,
                Name = group.Name,
                Members = group.UserGroups.Select(ug => ug.User.Username).ToList()  
            };

            return groupDTO;
        }


        // PUT: api/Groups/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutGroup(string id, Group @group)
        {
            if (id != @group.Id)
            {
                return BadRequest();
            }

            _context.Entry(@group).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!GroupExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Groups
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Group>> PostGroup(CreateGroupDtO createGroupDtO)
        {
            // Create a new Group entity and map properties from DTO
            var group = new Group
            {
                Id = Guid.NewGuid().ToString("N"),
                Name = createGroupDtO.Name
            };

            // Add the new Group to the database context
            _context.Groups.Add(group);
            try
            {
                // Attempt to save changes in the database
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                // Check if the Group already exists
                if (GroupExists(group.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }


            // Return the newly created GroupDTO with a CreatedAtAction to provide a location header
            return CreatedAtAction("GetGroup", new { id = group.Id }, group);
        }

        // DELETE: api/Groups/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGroup(string id)
        {
            var @group = await _context.Groups.FindAsync(id);
            if (@group == null)
            {
                return NotFound();
            }

            _context.Groups.Remove(@group);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool GroupExists(string id)
        {
            return _context.Groups.Any(e => e.Id == id);
        }
    }
}
