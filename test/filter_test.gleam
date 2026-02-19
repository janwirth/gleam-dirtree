import gleeunit/should
import gleam/option.{None}
import gleam/result
import dirtree.{Filepath, Dirpath} as dt
import gleam/string

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
    Ok(Dirpath(
      "/",
      [
        Dirpath(
          "a",
          [
            Dirpath(
              "b",
              [
                Dirpath(
                  "c",
                  [
                    Dirpath(
                      "d",
                      [
                        Dirpath(
                          "e",
                          [Dirpath("f", [], None)],
                          None,
                        ),
                      ],
                      None,
                    ),
                  ],
                  None,
                ),
              ],
              None,
            ),
          ],
          None,
        ),
      ],
      None,
    )),
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
    Ok(Dirpath(
      "/",
      [
        Dirpath(
          "a",
          [
            Dirpath(
              "b",
              [
                Dirpath(
                  "c",
                  [
                    Dirpath(
                      "d",
                      [
                        Dirpath(
                          "e",
                          [Dirpath("f", [], None)],
                          None,
                        ),
                        Filepath("logo1.png", None),
                      ],
                      None,
                    ),
                  ],
                  None,
                ),
              ],
              None,
            ),
          ],
          None,
        ),
      ],
      None,
    )),
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
    Ok(Dirpath(
      "/",
      [
        Dirpath(
          "a",
          [
            Dirpath(
              "b",
              [
                Dirpath(
                  "c",
                  [
                    Dirpath(
                      "d",
                      [Filepath("logo1.png", None)],
                      None,
                    ),
                  ],
                  None,
                ),
              ],
              None,
            ),
          ],
          None,
        ),
      ],
      None,
    )),
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
    Ok(Dirpath(
      "/",
      [
        Dirpath(
          "a",
          [
            Dirpath(
              "b",
              [
                Dirpath(
                  "c",
                  [
                    Dirpath(
                      "d",
                      [Filepath("logo1.png", None)],
                      None,
                    ),
                  ],
                  None,
                ),
              ],
              None,
            ),
          ],
          None,
        ),
      ],
      None,
    )),
  )
}
