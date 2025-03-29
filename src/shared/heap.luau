--!strict
--!optimize 2
--!native

-- heap.luau
-- Min-heap implmentation in luau

------------Dependencies-------------
--                                 --
-------------------------------------

export type Compare<T> = (a : T, b : T) -> boolean

export type Heap<T> = {
    pop : () -> T,
    push : (val : T) -> (),
    peek : () -> T,
    size : () -> number,
}

-- Heap Constructor
return function<T>(compare : Compare<T>) : Heap<T>

    local heap = {}

    -- Push a value into the heap (sorted based on the compare function)
    local function push(val : T) : ()
        table.insert(heap, val)
        local i = #heap
        while i > 1 do
            local curr = heap[i]
            local parentIndex = i // 2
            local parent = heap[parentIndex]
            if not compare(curr, parent) then
                break
            end
            heap[i], heap[parentIndex] = parent, curr
            i = parentIndex
        end
    end

    -- Pops the root value from the heap and reorders the heap
    local function pop() : T
        local n = #heap

        local root = heap[1]

        heap[1] = heap[n]
        heap[n] = nil
        n -= 1

        local i = 1
        while true do
            local left = 2 * i
            local right = left + 1
            local smallest = i

            local leftVal = heap[left]
            local rightVal = heap[right]
            local currentVal = heap[i]
            local smallestVal = currentVal

            if left <= n and compare(leftVal, smallestVal) then
                smallest = left
                smallestVal = leftVal
            end

            if right <= n and compare(rightVal, smallestVal) then
                smallest = right
                smallestVal = rightVal
            end

            if smallest == i then
                break
            end

            heap[i], heap[smallest] = smallestVal, currentVal
            i = smallest
        end
        
        return root
    end

    -- Peek at the root value of the heap without removing it
    local function peek() : T
        return heap[1]
    end

    -- Returns the size of the heap
    local function size() : number
        return #heap
    end

    return table.freeze{
        pop = pop,
        push = push,
        peek = peek,
        size = size,
    }
end
