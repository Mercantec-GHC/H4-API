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
        public async Task<ActionResult<IEnumerable<ActivityLogDtO>>> GetActivityLogs()
        {
            var activityLogs = await _context.ActivityLogs.ToListAsync();
            var activityLogDTOs = activityLogs.Select(activityLog => new ActivityLogDtO
            {
                Id = activityLog.Id,
                Date = activityLog.Date,
                Steps = activityLog.Steps,
                Distance = activityLog.Distance,
                StartTime = activityLog.StartTime,
                EndTime = activityLog.EndTime,
                Type = activityLog.Type,
                UserId = activityLog.UserId
            }).ToList();

            return activityLogDTOs;
        }

        // GET: api/ActivityLogs/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ActivityLogDtO>> GetActivityLog(string id)
        {
            var activityLog = await _context.ActivityLogs.FindAsync(id);

            if (activityLog == null)
            {
                return NotFound();
            }

            var activityLogDTOs = new ActivityLogDtO()
            {
                Id = activityLog.Id,
                Date = activityLog.Date,
                Steps = activityLog.Steps,
                Distance = activityLog.Distance,
                StartTime = activityLog.StartTime,
                EndTime = activityLog.EndTime,
                Type = activityLog.Type,
                UserId = activityLog.UserId
            };

            return activityLogDTOs;
        }

        // PUT: api/ActivityLogs/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutActivityLog(string id, ActivityLogDtO activityLogDTO)
        {
            if (id != activityLogDTO.Id)
            {
                return BadRequest();
            }

            var activityLog = new ActivityLog
            {
                Id = activityLogDTO.Id,
                Date = activityLogDTO.Date,                 
                Steps = activityLogDTO.Steps,
                Distance = activityLogDTO.Distance,
                StartTime = activityLogDTO.StartTime,
                EndTime = activityLogDTO.EndTime,
                Type = activityLogDTO.Type,
                UserId = activityLogDTO.UserId
            };

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
        public async Task<ActionResult<ActivityLogDtO>> PostActivityLog(ActivityLogDtO activityLogDTO)
        {
            var activityLog = new ActivityLog
            {
                Id = Guid.NewGuid().ToString("N"),
                Date = DateTime.UtcNow.AddHours(2),
                Steps = activityLogDTO.Steps,
                Distance = activityLogDTO.Distance,
                StartTime = activityLogDTO.StartTime,
                EndTime = activityLogDTO.EndTime,
                Type = activityLogDTO.Type,
                UserId = activityLogDTO.UserId
            };

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

            return CreatedAtAction("GetActivityLog", new { id = activityLog.Id }, activityLogDTO);
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

