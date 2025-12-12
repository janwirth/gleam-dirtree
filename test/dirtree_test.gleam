import gleeunit/should
import gleam/order
import gleam/result
import gleeunit
import dirtree.{type DirTree, Filepath, Dirpath} as dt
import gleam/string

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn filter_test() {
  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.filter_and_prune(fn(path) { !string.ends_with(path.name, ".png")} )
  |> should.equal(Error(Nil))

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.filter(fn(path) { !string.ends_with(path.name, ".png")} )
  |> should.equal(
    Ok(Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Dirpath("e", [Dirpath("f", [])])])])])])]))
  )

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.filter(fn(path) { !string.contains(path.name, "2")} )
  |> should.equal(
    Ok(Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Dirpath("e", [Dirpath("f", [])]), Filepath("logo1.png")])])])])]))
  )

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.filter_and_prune(fn(path) { !string.contains(path.name, "2")} )
  |> should.equal(
    Ok(Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Filepath("logo1.png")])])])])]))
  )

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.filter(fn(path) { !string.contains(path.name, "2")} )
  |> result.try(dt.prune)
  |> should.equal(
    Ok(Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Filepath("logo1.png")])])])])]))
  )
}

pub fn collapse_expand_test() {
  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> should.equal(
    Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Dirpath("e", [Dirpath("f", [Filepath("logo2.png")])]), Filepath("logo1.png")])])])])])
  )

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.collapse
  |> should.equal(
    Dirpath("/a/b/c/d", [Filepath("e/f/logo2.png"), Filepath("logo1.png")])
  )

  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.collapse
  |> dt.expand
  |> should.equal(
    Dirpath("/", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Dirpath("e", [Dirpath("f", [Filepath("logo2.png")])]), Filepath("logo1.png")])])])])])
  )

  dt.from_paths(
    "../examples",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.collapse
  |> dt.expand
  |> should.equal(
    Dirpath("..", [Dirpath("examples", [Dirpath("a", [Dirpath("b", [Dirpath("c", [Dirpath("d", [Dirpath("e", [Dirpath("f", [Filepath("logo2.png")])]), Filepath("logo1.png")])])])])])])
  )
}

pub fn files_test() {
  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.files
  |> should.equal([
    "/a/b/c/d/e/f/logo2.png",
    "/a/b/c/d/logo1.png",
  ])

  dt.from_paths(
    "../examples/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.files
  |> should.equal([
    "../examples/a/b/c/d/e/f/logo2.png",
    "../examples/a/b/c/d/logo1.png",
  ])
  
  dt.from_paths(
    "../examples",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "notes/defunct/old/really old/README.md",
      "empty-directory/",
      "notes/rEADME.md",
      "futuristic/pngs/png2.png",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.files
  |> should.equal([
    "../examples/.DS_Store",
    "../examples/.latter",
    "../examples/futuristic/pngs/png1.png",
    "../examples/futuristic/pngs/png2.png",
    "../examples/futuristic/svgs/svg1.png",
    "../examples/futuristic/svgs/svg2.png",
    "../examples/notes/defunct/old/really old/README.md",
    "../examples/notes/rEADME.md",
  ])

  dt.from_paths(
    "../examples/",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "notes/defunct/old/really old/README.md",
      "empty-directory/",
      "notes/rEADME.md",
      "futuristic/pngs/png2.png",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.files
  |> should.equal([
    "../examples/.DS_Store",
    "../examples/.latter",
    "../examples/futuristic/pngs/png1.png",
    "../examples/futuristic/pngs/png2.png",
    "../examples/futuristic/svgs/svg1.png",
    "../examples/futuristic/svgs/svg2.png",
    "../examples/notes/defunct/old/really old/README.md",
    "../examples/notes/rEADME.md",
  ])

  dt.from_paths(
    "/",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "notes/defunct/old/really old/README.md",
      "empty-directory/",
      "notes/rEADME.md",
      "futuristic/pngs/png2.png",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.files
  |> should.equal([
    "/.DS_Store",
    "/.latter",
    "/futuristic/pngs/png1.png",
    "/futuristic/pngs/png2.png",
    "/futuristic/svgs/svg1.png",
    "/futuristic/svgs/svg2.png",
    "/notes/defunct/old/really old/README.md",
    "/notes/rEADME.md",
  ])

  dt.from_paths(
    "/",
    []
  )
  |> dt.files
  |> should.equal([])

  dt.from_paths(
    "../examples",
    []
  )
  |> dt.files
  |> should.equal([])
}

pub fn terminals_test() {
  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
      "empty/",
    ],
  )
  |> dt.terminals
  |> should.equal([
    "/a/b/c/d/e/f/logo2.png",
    "/a/b/c/d/logo1.png",
    "/empty/",
  ])

  dt.from_paths(
    "../examples/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> dt.terminals
  |> should.equal([
    "../examples/a/b/c/d/e/f/logo2.png",
    "../examples/a/b/c/d/logo1.png",
  ])
  
  dt.from_paths(
    "../examples",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "notes/defunct/old/really old/README.md",
      "empty-directory/",
      "notes/rEADME.md",
      "futuristic/pngs/png2.png",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.terminals
  |> should.equal([
    "../examples/.DS_Store",
    "../examples/.latter",
    "../examples/empty-directory/",
    "../examples/futuristic/pngs/png1.png",
    "../examples/futuristic/pngs/png2.png",
    "../examples/futuristic/svgs/svg1.png",
    "../examples/futuristic/svgs/svg2.png",
    "../examples/notes/defunct/old/really old/README.md",
    "../examples/notes/rEADME.md",
  ])

  dt.from_paths(
    "../examples",
    []
  )
  |> dt.terminals
  |> should.equal([
    "../examples/",
  ])

  dt.from_paths(
    "/",
    [
      "futuristic/pngs/png1.png",
      "futuristic/svgs/svg1.png",
      "notes/defunct/old/really old/README.md",
      "empty-directory/",
      "notes/rEADME.md",
      "futuristic/pngs/png2.png",
      "futuristic/svgs/svg2.png",
      ".DS_Store",
      ".latter",
    ]
  )
  |> dt.terminals
  |> should.equal([
    "/.DS_Store",
    "/.latter",
    "/empty-directory/",
    "/futuristic/pngs/png1.png",
    "/futuristic/pngs/png2.png",
    "/futuristic/svgs/svg1.png",
    "/futuristic/svgs/svg2.png",
    "/notes/defunct/old/really old/README.md",
    "/notes/rEADME.md",
  ])

  dt.from_paths(
    "/",
    []
  )
  |> dt.terminals
  |> should.equal([
    "/",
  ])
}

pub fn from_paths_test() {
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
  |> should.equal(
    Dirpath(
      "../examples",
      [
        Filepath(".DS_Store"),
        Filepath(".latter"),
        Dirpath(
          "empty-directory",
          [],
        ),
        Dirpath(
          "futuristic",
          [
            Dirpath(
              "pngs",
              [
                Filepath("png1.png"),
                Filepath("png2.png"),
              ],
            ),
            Dirpath(
              "svgs",
              [
                Filepath("svg1.png"),
                Filepath("svg2.png"),
              ],
            ),
          ],
        ),
        Dirpath(
          "notes",
          [
            Filepath("README.md"),
            Filepath("old-README.md"),
          ],
        ),
      ],
    ),
  )
  
  dt.from_paths(
    "/",
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
  |> should.equal(
    Dirpath(
      "/",
      [
        Filepath(".DS_Store"),
        Filepath(".latter"),
        Dirpath(
          "empty-directory",
          [],
        ),
        Dirpath(
          "futuristic",
          [
            Dirpath(
              "pngs",
              [
                Filepath("png1.png"),
                Filepath("png2.png"),
              ],
            ),
            Dirpath(
              "svgs",
              [
                Filepath("svg1.png"),
                Filepath("svg2.png"),
              ],
            ),
          ],
        ),
        Dirpath(
          "notes",
          [
            Filepath("README.md"),
            Filepath("old-README.md"),
          ],
        ),
      ],
    ),
  )
}

pub fn sort_test() {
  let my_sort = fn(d1: DirTree, d2: DirTree) -> order.Order {
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
        Dirpath(
          "empty-directory",
          [],
        ),
        Dirpath(
          "futuristic",
          [
            Dirpath(
              "pngs",
              [
                Filepath("png1.png"),
                Filepath("png2.png"),
              ],
            ),
            Dirpath(
              "svgs",
              [
                Filepath("svg1.png"),
                Filepath("svg2.png"),
              ],
            ),
          ],
        ),
        Dirpath(
          "notes",
          [
            Filepath("README.md"),
            Filepath("old-README.md"),
          ],
        ),
        Filepath(".DS_Store"),
        Filepath(".latter"),
      ],
    ),
  )
}
