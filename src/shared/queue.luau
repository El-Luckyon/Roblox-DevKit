--!strict
--!native
--!optimize 2

-- queue.luau
-- a queue structure implementation.

export type Queue<T> = {
    push : (val : T) -> (),
    pop : () -> T,
    isEmpty : () -> boolean,
    size : () -> number,
    clear : () -> (),
    peek : () -> T
}

-- Queue constructor
return function<T>() : Queue<T>
    local items : {[number] : T} = {}
    local front : number = 0
    local back : number = 0

    -- Adds item to end of queue
    local function push(val : T)
        items[back] = val
        back += 1
    end

    -- Removes and returns the first item
    local function pop() : T
        local item = items[front]
        items[front] = nil
        front += 1
        return item
    end

    -- Checks if the queue is empty
    local function isEmpty() : boolean
        return front >= back
    end

    -- Returns the number of items in the queue
    local function size() : number
        return math.abs(back - front)
    end

    -- Clears the queue
    local function clear() : ()
        table.clear(items)
        front = 0
        back = 0
    end

    -- Returns the first item
    local function peek() : T
        return items[front]
    end

    return table.freeze{
        push = push,
        pop = pop,
        isEmpty = isEmpty,
        size = size,
        clear = clear,
        peek = peek,
    }
end
