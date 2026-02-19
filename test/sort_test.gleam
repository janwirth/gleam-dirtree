import gleeunit/should
import gleam/option.{None}
import gleam/order
import dirtree.{type DirTree, Filepath, Dirpath} as dt
import gleam/string

pub fn sort_test() {
  let my_sort = fn(d1: DirTree(Nil), d2: DirTree(Nil)) -> order.Order {
    case d1.name, d2.name {
      "." <> _, "." <> _ -> string.compare(d1.name, d2.name)
      "." <> _, _ -> order.Gt
      _, "." <> _ -> order.Lt
      _, _  -> string.compare(d1.name, d2.name)
    }
  }

  dt.from_paths(
    "../examples",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "empty-directory/",
      "notes/README.md",
      "futuristic/pngs/png2.png",
      "notes/old-README.md",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.sort(my_sort)
  |> should.equal(
    Dirpath(
      "../examples",
      [
        Dirpath("empty-directory", [], None),
        Dirpath(
          "futuristic",
          [
            Dirpath(
              "pngs",
              [
                Filepath("png1.png", None),
                Filepath("png2.png", None),
              ],
              None,
            ),
            Dirpath(
              "svgs",
              [
                Filepath("svg1.png", None),
                Filepath("svg2.png", None),
              ],
              None,
            ),
          ],
          None,
        ),
        Dirpath(
          "notes",
          [
            Filepath("README.md", None),
            Filepath("old-README.md", None),
          ],
          None,
        ),
        Filepath(".DS_Store", None),
        Filepath(".latter", None),
      ],
      None,
    ),
  )
}
