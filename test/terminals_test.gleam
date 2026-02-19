import gleeunit/should
import dirtree as dt

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
