// RUN: %target-typecheck-verify-swift -swift-version 5

struct S0<T> {
  func foo(_ other: Self) { }
}

class C0<T> {
  func foo(_ other: Self) { } // expected-error{{'Self' cannot be the type of a function argument in a class}}
}

enum E0<T> {
  func foo(_ other: Self) { }
}

// rdar://problem/21745221
struct X {
  typealias T = Int
}

extension X {
  struct Inner {
  }
}

extension X.Inner {
  func foo(_ other: Self) { }
}

// SR-695
class Mario {
  func getFriend() -> Self { return self } // expected-note{{overridden declaration is here}}
  func getEnemy() -> Mario { return self }
}
class SuperMario : Mario {
  override func getFriend() -> SuperMario { // expected-error{{cannot override a Self return type with a non-Self return type}}
    return SuperMario()
  }
  override func getEnemy() -> Self { return self }
}
final class FinalMario : Mario {
    override func getFriend() -> FinalMario {
        return FinalMario()
    }
}

// These references to Self are now possible (SE-0068)

class A<T> {
  typealias _Self = Self
  // expected-error@-1 {{'Self' is not available in a typealias}}
  let b: Int
  required init(a: Int) {
    print("\(Self.self).\(#function)")
    Self.y()
    b = a
  }
  static func z(n: Self? = nil) {
    // expected-error@-1 {{'Self' cannot be the type of a function argument in a class}}
    print("\(Self.self).\(#function)")
  }
  class func y() {
    print("\(Self.self).\(#function)")
    Self.z()
  }
  func x() -> A? {
    print("\(Self.self).\(#function)")
    Self.y()
    Self.z()
    let _: Self = Self.init(a: 66)
    return Self.init(a: 77) as? Self as? A
    // expected-warning@-1 {{conditional cast from 'Self' to 'Self' always succeeds}}
    // expected-warning@-2 {{conditional downcast from 'Self?' to 'A<T>' is equivalent to an implicit conversion to an optional 'A<T>'}}
  }
  func copy() -> Self {
    let copy = Self.init(a: 11)
    return copy
  }

  var copied: Self {
    let copy = Self.init(a: 11)
    return copy
  }
  subscript (i: Int) -> Self { // expected-error {{'Self' is not available as the type of a mutable subscript}}
    get {
      return Self.init(a: i)
    }
    set(newValue) {
      // expected-error@-1 {{'Self' cannot be the type of a function argument in a class}}
    }
  }
}

class B: A<Int> {
  let a: Int
  required convenience init(a: Int) {
    print("\(Self.self).\(#function)")
    self.init()
  }
  init() {
    print("\(Self.self).\(#function)")
    Self.y()
    Self.z()
    a = 99
    super.init(a: 88)
  }
  override class func y() {
    print("override \(Self.self).\(#function)")
  }
  override func copy() -> Self {
    let copy = super.copy() as! Self // supported
    return copy
  }
  override var copied: Self {
    let copy = super.copied as! Self // unsupported
    return copy
  }
}

class C {
  required init() {
  }

  func f() {
    func g(_: Self) {}
  }
  func g() {
    _ = Self.init() as? Self
    // expected-warning@-1 {{conditional cast from 'Self' to 'Self' always succeeds}}
  }
  func h(j: () -> Self) -> () -> Self {
    // expected-error@-1 {{'Self' cannot be the type of a function argument in a class}}
    // expected-error@-2 {{'Self' cannot be the type of a nested return value}}
    return { return self }
    // expected-error@-1 {{cannot convert value of type 'C' to closure result type 'Self'}}
  }

  let p0: Self?
  var p1: Self? // expected-error {{'Self' is not available as the type of a mutable property}}
  // expected-error@-1 {{'Self' cannot be the type of a function argument in a class}}
  // expected-error@-2 {{'Self' cannot be the type of a function argument in a class}}

  var prop: Self { // expected-error {{'Self' is not available as the type of a mutable property}}
    get {
      return self
    }
    set (newValue) { // expected-error {{'Self' cannot be the type of a function argument in a class}}
    }
  }
  subscript (i: Int) -> Self { // expected-error {{'Self' is not available as the type of a mutable subscript}}
    get {
      return self
    }
    set (newValue) { // expected-error {{'Self' cannot be the type of a function argument in a class}}
    }
  }
}

struct S1 {
  typealias _SELF = Self
  let j = 99.1
  subscript (i: Int) -> Self {
    get {
      return self
    }
    set(newValue) {
    }
  }
  var foo: Self {
    get {
      return self// as! Self
    }
    set (newValue) {
    }
  }
  func x(y: () -> Self, z: Self) {
  }
}

struct S2 {
  let x = 99
  struct S3<T> {
    let x = 99
    static func x() {
      Self.y()
    }
    func f() {
      func g(_: Self) {}
    }
    static func y() {
      print("HERE")
    }
    func foo(a: [Self]) -> Self? {
      Self.x()
      return self as? Self
      // expected-warning@-1 {{conditional cast from 'S2.S3<T>' to 'S2.S3<T>' always succeeds}}
    }
  }
  func copy() -> Self {
    let copy = Self.init()
    return copy
  }

  var copied: Self {
    let copy = Self.init()
    return copy
  }
}

extension S2 {
  static func x() {
    Self.y()
  }
  static func y() {
    print("HERE")
  }
  func f() {
    func g(_: Self) {}
  }
  func foo(a: [Self]) -> Self? {
    Self.x()
    return Self.init() as? Self
    // expected-warning@-1 {{conditional cast from 'S2' to 'S2' always succeeds}}
  }
  subscript (i: Int) -> Self {
    get {
      return Self.init()
    }
    set(newValue) {
    }
  }
}

enum E {
  static func f() {
    func g(_: Self) {}
    print("f()")
  }
  case e
  func h(h: Self) -> Self {
    Self.f()
    return .e
  }
}
