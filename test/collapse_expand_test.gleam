import gleeunit/should
import gleam/option.{None}
import dirtree.{Filepath, Dirpath} as dt

pub fn collapse_expand_test() {
  dt.from_paths(
    "/",
    [
      "a/b/c/d/e/f/logo2.png",
      "a/b/c/d/logo1.png",
    ],
  )
  |> should.equal(
    Dirpath(
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
                          [
                            Dirpath(
                              "f",
                              [Filepath("logo2.png", None)],
                              None,
                            ),
                          ],
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
    ),
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
    Dirpath("/a/b/c/d", [Filepath("e/f/logo2.png", None), Filepath("logo1.png", None)], None)
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
    Dirpath(
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
                          [
                            Dirpath(
                              "f",
                              [Filepath("logo2.png", None)],
                              None,
                            ),
                          ],
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
    ),
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
    Dirpath(
      "..",
      [
        Dirpath(
          "examples",
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
                              [
                                Dirpath(
                                  "f",
                                  [Filepath("logo2.png", None)],
                                  None,
                                ),
                              ],
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
        ),
      ],
      None,
    ),
  )
}
