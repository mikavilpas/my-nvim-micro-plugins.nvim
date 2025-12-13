import assert from "assert"
import { isSearchVisible } from "./utils/search-utils"

describe("my_copy_relative_path integrations", () => {
  it("can copy the relative path to the current file search result", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      isSearchVisible()

      // The search should be open and started from the root of the project.
      cy.typeIntoTerminal(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
      // wait for the file to be selected
      isSearchVisible()

      // the file should be selected - copy the relative path
      cy.typeIntoTerminal("{control+y}")
      cy.contains("🔎").should("not.exist")

      // the relative path should be copied to the register
      nvim.runExCommand({ command: "register z" }).then((output) => {
        expect(output.value).to.contain(
          "../../routes/posts.$postId/adjacent-file.txt",
        )
      })
    })
  })

  it("can copy the relative path to the current grep search result", () => {
    //
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      isSearchVisible()
      cy.typeIntoTerminal("hello from the test", { delay: 10 }) // this very test file

      cy.contains("copy-relative-path.cy")
      // wait for the file to be selected
      cy.contains("this very test file")

      // copy the relative path
      cy.typeIntoTerminal("{control+y}")

      // The relative path should be copied to the clipboard. Paste it
      nvim.runExCommand({ command: "register z" }).then((output) => {
        expect(output.value).to.contain(
          // line numbers should have been removed
          "../../../cypress/e2e/copy-relative-path.cy",
        )
      })
    })
  })

  it("can copy the relative path to multiple grep search results", () => {
    //
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      isSearchVisible()
      cy.typeIntoTerminal("file.txt$") // this very test file

      cy.contains(
        nvim.dir.contents["other-subdirectory"].contents["other-sub-file.txt"]
          .name,
      )
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )

      // select the files and verify they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.typeIntoTerminal("{control+i}")

      // copy the relative path
      cy.typeIntoTerminal("{control+y}")
      cy.contains("🔎").should("not.exist")

      // The relative path should be copied to the clipboard.
      nvim
        .runLuaCode({ luaCode: `return vim.fn.getreg("z")` })
        .then((output) => {
          const result = output.value

          assert(result)
          assert(typeof result === "string")

          const lines = result.split("\n").toSorted()
          expect(lines.join("\n")).to.eql(
            [
              "../../other-subdirectory/other-sub-file.txt",
              "../../routes/posts.$postId/adjacent-file.txt",
            ].join("\n"),
          )
        })
    })
  })

  it("supports multiple file results", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      isSearchVisible()

      // The search should be open and started from the root of the project.
      // Narrow it down to some known files
      cy.typeIntoTerminal("posts.postId/.txt", { delay: 100 })
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      )

      // Select the files. They should have a new color after this to indicate
      // they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.typeIntoTerminal("{control+i}")
      // snacks should be showing the count of selected files
      cy.contains(`(2)`)

      // copy the relative path. This should close the picker
      cy.typeIntoTerminal("{control+y}")
      cy.contains("🔎").should("not.exist")

      // The relative path should be copied to the clipboard.
      nvim
        .runLuaCode({ luaCode: `return vim.fn.getreg("z")` })
        .then((output) => {
          expect(output.value).to.eql(
            [
              "../../routes/posts.$postId/adjacent-file.txt",
              "../../routes/posts.$postId/should-be-excluded-file.txt",
            ].join("\n"),
          )
        })
    })
  })
})
