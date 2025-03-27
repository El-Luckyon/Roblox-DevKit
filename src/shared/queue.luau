--!strict
--!native
--!optimize 2

-- queue.luau
-- a queue & stack data structure implementation.

-- even tho its called a queue it has pop and push in both ends so can be used as a stack.

export type Queue<T> = {
    pushBack : (val : T) -> (),
    pushFront : (val : T) -> (),
    popBack : () -> T,
    popFront : () -> T,
    isEmpty : () -> boolean,
    size : () -> number,
    clear : () -> (),
    getFront : () -> T,
    getBack : () -> T,
}

-- Queue constructor
return function<T>() : Queue<T>
    local items : {[number] : T} = {}
    local front : number = 0
    local back : number = 0

    -- adds item to end of queue
    local function pushBack(val : T)
        back += 1
        items[back] = val
    end

    -- adds item to front of queue
    local function pushFront(val : T)
        front -= 1
        items[front] = val
    end

    -- removes and returns the last item
    local function popBack() : T
        local item = items[back]
        items[back] = nil
        back -= 1
        return item
    end

    -- removes and returns the first item
    local function popFront() : T
        local item = items[front]
        items[front] = nil
        front += 1
        return item
    end

    -- checks if the queue is empty
    local function isEmpty() : boolean
        return front > back
    end

    -- returns the number of items in the queue
    local function size() : number
        return back - front + 1
    end

    -- clears the queue
    local function clear() : ()
        table.clear(items)
        front = 0
        back = 0
    end

    -- returns the first item
    local function getFront() : T
        return items[front]
    end

    -- returns the last item
    local function getBack() : T
        return items[back]
    end

    return table.freeze{
        pushBack = pushBack,
        pushFront = pushFront,
        popBack = popBack,
        popFront = popFront,
        isEmpty = isEmpty,
        size = size,
        clear = clear,
        getFront = getFront,
        getBack = getBack,
    }
end
