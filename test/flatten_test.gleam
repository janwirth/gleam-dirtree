import gleeunit/should
import gleam/option.{None}
import dirtree as dt

pub fn flatten_test() {
  dt.from_paths(
    "/",
    ["a/b/c.png"],
  )
  |> dt.flatten
  |> should.equal([
    dt.FlattenedItem(item_name: "/", path: [], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "a", path: ["/"], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "b", path: ["/", "a"], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "c.png", path: ["/", "a", "b"], item_type: dt.File, meta: None),
  ])

  dt.from_paths(
    "/",
    [
      "a/b/logo1.png",
      "a/b/logo2.png",
    ],
  )
  |> dt.flatten
  |> should.equal([
    dt.FlattenedItem(item_name: "/", path: [], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "a", path: ["/"], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "b", path: ["/", "a"], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "logo1.png", path: ["/", "a", "b"], item_type: dt.File, meta: None),
    dt.FlattenedItem(item_name: "logo2.png", path: ["/", "a", "b"], item_type: dt.File, meta: None),
  ])

  dt.from_paths(
    "/",
    ["x.png"],
  )
  |> dt.flatten
  |> should.equal([
    dt.FlattenedItem(item_name: "/", path: [], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "x.png", path: ["/"], item_type: dt.File, meta: None),
  ])

  dt.from_paths(
    "/",
    ["empty/"],
  )
  |> dt.flatten
  |> should.equal([
    dt.FlattenedItem(item_name: "/", path: [], item_type: dt.Dir, meta: None),
    dt.FlattenedItem(item_name: "empty", path: ["/"], item_type: dt.Dir, meta: None),
  ])

  dt.from_paths(
    "/",
    [],
  )
  |> dt.flatten
  |> should.equal([
    dt.FlattenedItem(item_name: "/", path: [], item_type: dt.Dir, meta: None),
  ])
}
