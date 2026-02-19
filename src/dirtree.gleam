import gleam/order
import gleam/option.{type Option, None, Some}
import gleam/list
import gleam/string

/// The basic type encoding a directory tree.
/// 
/// A diretory tree either consists of a path to a file,
/// possibly non-simple, or of a path to a recursively
/// given list of DirTree.
///
/// Note that a filepath name should be nonempty, but a
/// dirpath, as a relative path from the current working
/// directory, may be empty.
/// 
/// **Examples**
/// 
/// - `Filepath("examples/pngs/logo.png")`
/// - `Dirpath("../src", [])`
/// - `Dirpath("", [])`
/// - `Dirpath("examples", [Filepath("pngs/logo.png")])`
pub type DirTree(a) {
  Filepath(name: String, meta: Option(a))
  Dirpath(name: String, contents: List(DirTree(a)), meta: Option(a))
}

fn from_terminals_acc(
  previous: List(DirTree(a)),
  under_construction: Option(#(String, List(#(List(String), Option(a))))),
  remaining: List(#(List(String), Option(a))),
) -> List(DirTree(a)) {
  let package_current = fn(name: String, decomposed_paths: List(#(List(String), Option(a)))) {
    assert name != ""
    case decomposed_paths {
      [#([""], meta)] -> Dirpath(name, [], meta)
      _ -> {
        let subdirs = from_terminals_acc([], None, decomposed_paths |> list.reverse)
        Dirpath(name, subdirs, None)
      }
    }
  }

  case remaining, under_construction {
    [], None -> previous |> list.reverse

    [], Some(#(name, decomposed_paths)) -> {
      let constructed = package_current(name, decomposed_paths)
      [constructed, ..previous] |> list.reverse
    }

    [#(first, meta), ..rest], None -> {
      case first {
        [] -> panic

        [""] -> from_terminals_acc(previous, None, rest)

        [filename] -> {
          let constructed = Filepath(filename, meta)
          from_terminals_acc([constructed, ..previous], None, rest)
        }

        [dirname, ..decomposed_path] -> {
          assert dirname != ""
          from_terminals_acc(previous, Some(#(dirname, [#(decomposed_path, meta)])), rest)
        }
      }
    }

    [#(first, meta), ..rest], Some(#(name, decomposed_paths)) -> {
      case first {
        [] -> panic

        [""] -> panic

        [filename] -> {
          assert filename != name
          let constructed1 = package_current(name, decomposed_paths)
          let constructed2 = Filepath(filename, meta)
          from_terminals_acc(
            [constructed2, constructed1, ..previous],
            None,
            rest,
          )
        }

        [dirname, ..decomposed_path] if dirname == name -> {
          from_terminals_acc(
            previous,
            Some(#(name, [#(decomposed_path, meta), ..decomposed_paths])),
            rest,
          )
        }

        [dirname, ..decomposed_path] if dirname != name -> {
          let constructed1 = package_current(name, decomposed_paths)
          from_terminals_acc(
            [constructed1, ..previous],
            Some(#(dirname, [#(decomposed_path, meta)])),
            rest,
          )
        }

        _ -> panic
      }
    }
  }
}

/// A function that constructs a `DirTree` from a path to a
/// directory, forming the dirpath, and a list of relative paths
/// from within that directory to either files or empty directories,
/// i.e., to the "terminal elements" of the directory tree. Terminals
/// that end in `/` are interpreted as empty directories, others are
/// interpreted as filepaths. The given set of terminals should be
/// prefix-free, but the order of terminals is arbitrary and will
/// be ignored.
/// 
/// In particular, intermediate directories contained within the 
/// paths of other terminals should NOT be listed separately, lest
/// they be confused with files or empty directories!
/// 
/// **Examples**
/// 
/// ```gleam
/// let tree = dirtree.from_terminals(
///   "../examples",
///   [
///     "futuristic/pngs/png2.png",
///     "futuristic/svgs/svg2.png",
///     "futuristic/svgs/svg1.png",
///     "notes/README.md",
///     "futuristic/pngs/png1.png",
///     "empty-directory/",
///   ],
/// )
/// 
/// tree
/// |> dt.pretty_print(1)
/// |> string.join("\n")
/// |> io.println
/// 
/// // ->
/// //
/// // ../examples
/// //    ├─ empty-directory
/// //    ├─ futuristic
/// //    │  ├─ pngs
/// //    │  │  ├─ png1.png
/// //    │  │  └─ png2.png
/// //    │  └─ svgs
/// //    │     ├─ svg1.png
/// //    │     └─ svg2.png
/// //    └─ notes
/// //       ├─ README.md
/// //       └─ old-README.md
/// ```
pub fn from_terminals(
  dirpath: String,
  terminals: List(#(String, Option(a))),
) -> DirTree(a) {
  assert list.all(
    terminals,
    fn(t) {
      let #(path, _) = t
      !string.starts_with(path, "/")
    },
  )

  let terminals =
    terminals
    |> list.sort(fn(a, b) {
      let #(pa, _) = a
      let #(pb, _) = b
      string.compare(pa, pb)
    })
    |> list.map(fn(t) {
      let #(path, meta) = t
      #(string.split(path, "/"), meta)
    })

  let dirpath = case string.ends_with(dirpath, "/") && dirpath != "/" {
    True -> string.drop_end(dirpath, 1)
    False -> dirpath
  }

  Dirpath(dirpath, from_terminals_acc([], None, terminals), None)
}

/// Convenience: build from list of path strings, all with None meta.
pub fn from_paths(dirpath: String, paths: List(String)) -> DirTree(Nil) {
  from_terminals(dirpath, list.map(paths, fn(p) { #(p, None) }))
}

/// Sorts a `DirTree` recursively from a given order
/// function.
/// 
/// **Examples**
/// 
/// ```gleam
/// let tree = dt.from_terminals(
///   "../examples",
///   [
///     "futuristic/pngs/png1.png",
///     "futuristic/svgs/svg1.png",
///     "empty-directory/",
///     ".DS_store",
///     "notes/README.md",
///     "futuristic/pngs/png2.png",
///     "notes/old-README.md",
///     "futuristic/svgs/svg2.png",
///     ".latter",
///   ]
/// )
///
/// // puts dotfiles last instead of first
/// let my_sort = fn(d1: DirTree, d2: DirTree) -> order.Order {
///   case d1.name, d2.name {
///     "." <> _, "." <> _ -> string.compare(d1.name, d2.name)
///     "." <> _, _ -> order.Gt
///     _, "." <> _ -> order.Lt
///     _, _  -> string.compare(d1.name, d2.name)
///   }
/// }
///
/// tree
/// |> dt.sort(my_sort)
/// |> dt.pretty_print(1)
/// |> string.join("\n")
/// |> io.println
/// 
/// // ->
/// // 
/// // ../examples
/// //    ├─ empty-directory
/// //    ├─ futuristic
/// //    │  ├─ pngs
/// //    │  │  ├─ png1.png
/// //    │  │  └─ png2.png
/// //    │  └─ svgs
/// //    │     ├─ svg1.png
/// //    │     └─ svg2.png
/// //    ├─ notes
/// //    │  ├─ README.md
/// //    │  └─ old-README.md
/// //    ├─ .DS_store
/// //    └─ .latter
/// ```
pub fn sort(
  tree: DirTree(a),
  order: fn(DirTree(a), DirTree(a)) -> order.Order,
) -> DirTree(a) {
  case tree {
    Filepath(_, _) -> tree
    Dirpath(name, contents, meta) -> {
      let contents =
        contents
        |> list.map(sort(_, order))
        |> list.sort(order)
      Dirpath(name, contents, meta)
    }
  }
}

/// Recursively map a `DirTree` using a 1-to-1 transform. Maps children before parents.
pub fn map(
  tree: DirTree(a),
  m: fn(DirTree(a)) -> DirTree(a),
) -> DirTree(a) {
  case tree {
    Filepath(_, _) -> m(tree)
    Dirpath(name, contents, meta) -> {
      let contents = list.map(contents, map(_, m))
      m(Dirpath(name, contents, meta))
    }
  }
}

/// Recursively map a `DirTree` using a 1-to-many transform.
/// Maps children before parents.
pub fn flat_map(
  tree: DirTree(a),
  m: fn(DirTree(a)) -> List(DirTree(a)),
) -> List(DirTree(a)) {
  case tree {
    Filepath(_, _) -> m(tree)
    Dirpath(name, contents, meta) -> {
      let contents = list.flat_map(contents, flat_map(_, m))
      m(Dirpath(name, contents, meta))
    }
  }
}

/// Recursively filters a `DirTree` using a boolean condition
/// applied in depth-first fashion,
///
/// Returns an `Error(Nil)` if the root of the tree resolves
/// to a DirTree instance that does not meet the condition.
///
/// Does not filter out empty directories. See also `prune`
/// and `filter_and_prune`.
pub fn filter(
  tree: DirTree(a),
  condition: fn(DirTree(a)) -> Bool,
) -> Result(DirTree(a), Nil) {
  let m = fn(t) {
    case condition(t) {
      False -> []
      True -> [t]
    }
  }
  case flat_map(tree, m) {
    [] -> Error(Nil)
    [root] -> Ok(root)
    _ -> panic
  }
}

/// Recursively removes empty directories in depth-first fashion.
/// Returns Error(Nil) if the root resolves to an empty directory.
pub fn prune(
  tree: DirTree(a),
) -> Result(DirTree(a), Nil) {
  let condition = fn(t) {
    case t {
      Dirpath(_, [], _) -> False
      _ -> True
    }
  }
  filter(tree, condition)
}

/// Recursively filters a `DirTree` using a boolean condition
/// applied in depth-first fashion while also removing empty
/// directories.
/// 
/// Returns `Error(Nil)` if the root of the tree is filtered
/// out by the process.
pub fn filter_and_prune(
  tree: DirTree(a),
  condition: fn(DirTree(a)) -> Bool,
) -> Result(DirTree(a), Nil) {
  let updated_condition = fn(t) {
    case t {
      Dirpath(_, [], _) -> False
      _ -> condition(t)
    }
  }
  filter(tree, updated_condition)
}

/// Concatenates names of directories containing a single child
/// with that of their child.
/// 
/// **Examples**
/// 
/// ```gleam
/// Dirpath("a", [Dirpath("b", [Filepath("foo.png")])])
/// |> collapse
/// 
/// // -> Filepath("a/b/foo.png")
/// ````
pub fn collapse(
  tree: DirTree(a),
) -> DirTree(a) {
  let m = fn(t: DirTree(a)) -> DirTree(a) {
    case t {
      Dirpath(name, [one], _) -> {
        let prefix = case name {
          "/" -> name
          _ -> name <> "/"
        }
        case one {
          Filepath(_, meta) -> Filepath(prefix <> one.name, meta)
          Dirpath(_, contents, meta) -> Dirpath(prefix <> one.name, contents, meta)
        }
      }
      _ -> t
    }
  }
  tree |> map(m)
}

/// Expands compound filepaths and dirpaths into
/// nested sequences of atomic directories.
/// 
/// **Examples**
/// 
/// ```gleam
/// Dirpath("a/b/c", [Filepath("z")])
/// |> expand
/// 
/// // ->
/// //
/// // Dirpath("a", [Dirpath("b", [Dirpath("c", [Filepath("z")])])])
/// ```
pub fn expand(
  tree: DirTree(a),
) -> DirTree(a) {
  let m = fn(t: DirTree(a)) -> DirTree(a) {
    case string.contains(t.name, "/") && t.name != "/" {
      False -> t
      True -> {
        let assert [first, ..rest] = string.split(t.name, "/") |> list.reverse
        let nucleus = case t {
          Filepath(_, meta) -> Filepath(first, meta)
          Dirpath(_, contents, meta) -> Dirpath(first, contents, meta)
        }
        assert rest != []
        list.fold(
          rest,
          nucleus,
          fn(acc, dirname) {
            let dirname = case dirname {
              "" -> "/"
              _ -> dirname
            }
            Dirpath(dirname, [acc], None)
          }
        )
      }
    }
  }
  tree |> map(m)
}

/// Returns a list of files in the DirTree in the same order
/// as they appear in the tree.
pub fn files(
  tree: DirTree(a),
) -> List(String) {
  case tree {
    Filepath(path, _) -> [path]
    Dirpath(path, contents, _) -> {
      let prefix = case path {
        "/" -> "/"
        _ -> path <> "/"
      }
      list.flat_map(contents, files)
      |> list.map(fn(f) { prefix <> f })
    }
  }
}

/// Returns a list of paths to terminal elements of a `DirTree`,
/// these being either files or empty directories.
/// 
/// Empty directories are encoded by strings terminated with a `/`.
pub fn terminals(
  tree: DirTree(a),
) -> List(String) {
  case tree {
    Filepath(path, _) -> [path]
    Dirpath(path, contents, _) -> {
      case contents, path {
        [], "/" -> [path]
        [], _ -> [path <> "/"]
        _, _ -> {
          let prefix = case path {
            "/" -> "/"
            _ -> path <> "/"
          }
          list.flat_map(contents, terminals)
          |> list.map(fn(f) { prefix <> f })
        }
      }
    }
  }
}

type PrettyPrinterMarginBlocks {
  PrettyPrinterMarginBlocks(
    t: String, // "├─ "
    v: String, // "│  "
    l: String, // "└─ "
    s: String, // "   "
  )
}

fn pretty_printer_add_margin(
  lines: List(String),
  is_last: Bool,
  blocks: PrettyPrinterMarginBlocks,
) -> List(String) {
  case is_last {
    False -> list.index_map(
      lines,
      fn (line, i) {
        case i == 0 {
          True -> blocks.t <> line
          False -> blocks.v <> line
        }
      }
    )
    True -> list.index_map(
      lines,
      fn (line, i) {
        case i == 0 {
          True -> blocks.l <> line
          False -> blocks.s <> line
        }
      }
    )
  }
}

fn pretty_print_internal(
  tree: DirTree(a),
  blocks: PrettyPrinterMarginBlocks,
) -> List(String) {
  case tree {
    Filepath(path, _) -> [path]
    Dirpath(path, children, _) -> {
      let num_children = children |> list.length
      let xtra_margin = case string.reverse(path |> string.drop_end(1)) |> string.split_once("/") {
        Ok(#(_, after)) -> string.length(after) + 1
        _ -> 0
      }
      let xtra_margin = string.repeat(" ", xtra_margin)
      list.index_map(
        children,
        fn (child, i) {
          pretty_print_internal(child, blocks)
          |> pretty_printer_add_margin(i == num_children - 1, blocks)
          |> list.map(fn(line){xtra_margin <> line})
        }
      )
      |> list.flatten
      |> list.prepend(path)
    }
  }
}

fn blocks_4_indentation(
  indentation: Int,
) -> PrettyPrinterMarginBlocks {
  PrettyPrinterMarginBlocks(
    t: "├" <> string.repeat("─", indentation) <> " ",
    v: "│" <> string.repeat(" ", indentation + 1),
    l: "└" <> string.repeat("─", indentation) <> " ",
    s: string.repeat(" ", indentation + 2),
  )
}

/// Pretty-print a `DirTree` using a given level of indentation.
/// The result is given as a List(String) to allow a possible 
/// consumer to more easily add extra margin or embed the tree 
/// in a larger ASCII graphic.
/// 
/// **Examples**
/// 
/// ```gleam
/// let tree = dt.from_terminals(
///   "/",
///   [
///     "futuristic/pngs/png1.png",
///     "futuristic/svgs/svg1.png",
///     "empty-directory/",
///     "notes/README.md",
///     "futuristic/pngs/png2.png",
///     "notes/old-README.md",
///     "futuristic/svgs/svg2.png",
///   ]
/// )
///
/// tree
/// |> dt.sort(my_sort)
/// |> dt.pretty_print(10)
/// |> string.join("\n")
/// |> io.println
/// 
/// // ->
/// //
/// // /
/// // ├────────── empty-directory
/// // ├────────── futuristic
/// // │           ├────────── pngs
/// // │           │           ├────────── png1.png
/// // │           │           └────────── png2.png
/// // │           └────────── svgs
/// // │                       ├────────── svg1.png
/// // │                       └────────── svg2.png
/// // └────────── notes
/// //             ├────────── README.md
/// //             └────────── old-README.md
/// ```
pub fn pretty_print(tree: DirTree(a), indentation: Int) -> List(String) {
  pretty_print_internal(tree, blocks_4_indentation(indentation))
}
