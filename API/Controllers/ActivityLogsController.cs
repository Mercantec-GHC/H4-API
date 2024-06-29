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
    public class ActivityLogsController : ControllerBase
    {
        private readonly AppDBContext _context;

        public ActivityLogsController(AppDBContext context)
        {
            _context = context;
        }

        // GET: api/ActivityLogs
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityLog>>> GetActivityLogs()
        {
            return await _context.ActivityLogs.ToListAsync();
        }

        // GET: api/ActivityLogs/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ActivityLog>> GetActivityLog(string id)
        {
            var activityLog = await _context.ActivityLogs.FindAsync(id);

            if (activityLog == null)
            {
                return NotFound();
            }

            return activityLog;
        }

        // PUT: api/ActivityLogs/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutActivityLog(string id, ActivityLog activityLog)
        {
            if (id != activityLog.Id)
            {
                return BadRequest();
            }

            _context.Entry(activityLog).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ActivityLogExists(id))
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

        // POST: api/ActivityLogs
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<ActivityLog>> PostActivityLog(ActivityLog activityLog)
        {
            _context.ActivityLogs.Add(activityLog);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException)
            {
                if (ActivityLogExists(activityLog.Id))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtAction("GetActivityLog", new { id = activityLog.Id }, activityLog);
        }

        // DELETE: api/ActivityLogs/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteActivityLog(string id)
        {
            var activityLog = await _context.ActivityLogs.FindAsync(id);
            if (activityLog == null)
            {
                return NotFound();
            }

            _context.ActivityLogs.Remove(activityLog);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool ActivityLogExists(string id)
        {
            return _context.ActivityLogs.Any(e => e.Id == id);
        }
    }
}
