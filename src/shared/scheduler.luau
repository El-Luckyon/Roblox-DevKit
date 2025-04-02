--!strict
--!native
--!optimize 2

-- scheduler.luau
-- This module provides a scheduler for running functions at a later time or at regular interval

------------Dependencies-------------
-- heap.luau                       --
-------------------------------------

export type callback = (...any) -> ...any

export type jobInterface = {
    every : (interval : number) -> jobInterface,
    after : (delay : number) -> jobInterface,
    cancel : () -> (),
}

export type job = {
    func : callback,
    canceled : boolean,
    executeTime : number,
    interval : number,
}

local RunService = game:GetService("RunService")

local MAX_PROCESSING_TIME = 0.05

local heaps = require(script.Parent.heap)

-- The compare function for the heap. It compares the executeTime of two jobs.
local function compare(a : job, b : job) : boolean
    return a.executeTime < b.executeTime
end

local jobHeap = heaps(compare)

local push = jobHeap.push
local pop = jobHeap.pop
local peek = jobHeap.peek
local size = jobHeap.size
local clock = os.clock

-- Update function to run the jobs
local function update() : ()
    local startTime = clock()
    while size() > 0 and peek().executeTime <= clock() do
        local job = pop()
        if job.canceled then continue end
        job.func()
        local interval = job.interval
		if interval > 0 then
			job.executeTime = clock() + interval
			push(job)
		end
        if clock() - startTime > MAX_PROCESSING_TIME then
            return
        end
	end
end

-- Job constructor
local function createJob(callback : callback) : jobInterface
    local executeTime = 0
    local interval = 0

    local interface : jobInterface
    local job : job

    -- Sets the time the job should be repeated after
    local function every(val : number) : jobInterface
       interval = val
       return interface
    end

    -- Sets the time to start when running the job
    local function after(val : number) : jobInterface
        executeTime = clock() + val
        job = {
            func = callback,
            executeTime = executeTime,
            interval = interval,
            canceled = false,
        }
        push(job)
        return interface
    end

    -- Cancels the job if it is scheduled
    local function cancel() : ()
        if job then
            job.canceled = true
        end
    end

    interface = table.freeze({
        every = every,
        after = after,
        cancel = cancel,
    })
    return interface
end

RunService.Heartbeat:Connect(update)

return createJob
