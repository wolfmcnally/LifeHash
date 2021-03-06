//
//  Grid.swift
//  WolfCore
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//
//  Created by Wolf McNally on 1/20/16.
//

import Foundation

class Grid<T: Equatable>: Equatable {
    let size: IntSize
    let maxX: Int
    let maxY: Int
    let capacity: Int
    let storage: UnsafeMutablePointer<T>

    init(size: IntSize, initialValue: T) {
        self.size = size
        maxX = size.width - 1
        maxY = size.height - 1
        capacity = size.width * size.height
        storage = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        storage.initialize(repeating: initialValue, count: capacity)
    }

    deinit {
        storage.deallocate()
    }

    func isValid(coordinate point: IntPoint) -> Bool {
        guard point.x >= 0 else { return false }
        guard point.y >= 0 else { return false }
        guard point.x < size.width else { return false }
        guard point.y < size.height else { return false }
        return true
    }

    @usableFromInline func offset(for coord: IntPoint) -> Int {
        let o = coord.y * size.width + coord.x
        guard o < capacity else { fatalError() }
        return o
    }

    @inlinable func getValue(atCoordinate coord: IntPoint) -> T {
        return storage[offset(for: coord)]
    }

    @inlinable func setValue(_ value: T, atCoordinate coord: IntPoint) {
        storage[offset(for: coord)] = value
    }

    @inlinable func getValue(atCircularCoordinate coord: IntPoint) -> T {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        return getValue(atCoordinate: IntPoint(x: cx, y: cy))
    }

    @inlinable func setValue(_ value: T, atCircularCoordinate coord: IntPoint) {
        let cx = makeCircularIndex(at: coord.y, count: size.height)
        let cy = makeCircularIndex(at: coord.x, count: size.width)
        setValue(value, atCoordinate: IntPoint(x: cx, y: cy))
    }

    @inlinable func forAll(_ f: (IntPoint) -> Void) {
        for y in 0..<size.height {
            for x in 0..<size.width {
                f(IntPoint(x: x, y: y))
            }
        }
    }

    @inlinable func setAll(_ value: T) {
        forAll { p in
            self[p] = value
        }
    }

    @inlinable func forNeighborhood(at point: IntPoint, f: (_ o: IntPoint, _ p: IntPoint) -> Void) {
        for oy in -1 ... 1 {
            for ox in -1 ... 1 {
                let o = IntPoint(x: ox, y: oy)
                let p = IntPoint(x: makeCircularIndex(at: ox + point.x, count: size.width), y: makeCircularIndex(at: oy + point.y, count: size.height))
                f(o, p)
            }
        }
    }

    @inlinable subscript(point: IntPoint) -> T {
        get { return self.getValue(atCoordinate: point) }
        set { self.setValue(newValue, atCoordinate: point) }
    }

    @inlinable subscript(x: Int, y: Int) -> T {
        get { return self[IntPoint(x: x, y: y)] }
        set { self[IntPoint(x: x, y: y)] = newValue }
    }

    @inlinable func equals(_ g: Grid<T>) -> Bool {
        guard size == g.size else { return false }
        return true
    }

    func stringRepresentation(of value: T) -> String {
        return "\(value)"
    }

    var stringRepresentation: String {
        var result = ""

        for y in 0..<size.height {
            for x in 0..<size.width {
                let p = IntPoint(x: x, y: y)
                let value = self[p]
                result.append(stringRepresentation(of: value))
                if x != maxX {
                    result.append(" ")
                }
            }
            if y != maxY {
                result.append("\n")
            }
        }

        return result
    }

    func dump() {
        print(stringRepresentation)
    }
}

func == <T>(lhs: Grid<T>, rhs: Grid<T>) -> Bool {
    return lhs.equals(rhs)
}
