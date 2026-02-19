import gleeunit/should
import gleam/option.{None}
import dirtree.{Filepath, Dirpath} as dt

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
        Filepath(".DS_Store", None),
        Filepath(".latter", None),
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
      ],
      None,
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
        Filepath(".DS_Store", None),
        Filepath(".latter", None),
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
      ],
      None,
    ),
  )
}
