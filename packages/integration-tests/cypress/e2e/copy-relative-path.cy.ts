import { flavors } from "@catppuccin/palette"
import { hasColor, rgbify } from "./color-utils"

const darkTheme = flavors.macchiato.colors

describe("my_copy_relative_path integrations", () => {
  it("can copy the relative path to the current telescope file search result", () => {
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      cy.contains("Find files")

      // The search should be open and started from the root of the project.
      cy.typeIntoTerminal(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )

      // the file should be selected - copy the relative path
      cy.typeIntoTerminal("{control+y}")
      cy.contains("Find files").should("not.exist")

      // the relative path should be copied to the register
      cy.runExCommand({ command: "register z" }).then((output) => {
        expect(output.value).to.contain(
          "../../routes/posts.$postId/adjacent-file.txt",
        )
      })
    })
  })

  it("can copy the relative path to the current telescope grep search result", () => {
    //
    cy.visit("/")
    cy.startNeovim().then((_dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      cy.contains("Live grep in")
      cy.typeIntoTerminal("hello from the test") // this very test file

      cy.contains("copy-relative-path.cy")

      // copy the relative path
      cy.typeIntoTerminal("{control+y}")
      cy.contains("Live grep in").should("not.exist")

      // The relative path should be copied to the clipboard. Paste it
      cy.runExCommand({ command: "register z" }).then((output) => {
        expect(output.value).to.contain(
          // line numbers should have been removed
          "../../../cypress/e2e/copy-relative-path.cy",
        )
      })
    })
  })

  it("can copy the relative path to multiple telescope grep search results", () => {
    //
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      cy.contains("Live grep in")
      cy.typeIntoTerminal("file.txt$") // this very test file

      hasColor(
        dir.contents["other-subdirectory"].contents["other-sub-file.txt"].name,
        darkTheme.text.rgb,
      )
      hasColor(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
        darkTheme.text.rgb,
      )

      // select the files and verify they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.typeIntoTerminal("{control+i}")
      hasColor(
        dir.contents["other-subdirectory"].contents["other-sub-file.txt"].name,
        darkTheme.yellow.rgb,
      )
      hasColor("adjacent-", darkTheme.yellow.rgb)

      // copy the relative path
      cy.typeIntoTerminal("{control+y}")

      // The relative path should be copied to the clipboard.
      cy.runLuaCode({ luaCode: `return vim.fn.getreg("z")` }).then((output) => {
        expect(output.value).to.eql(
          [
            "../../other-subdirectory/other-sub-file.txt",
            "../../routes/posts.$postId/adjacent-file.txt",
          ].join("\n"),
        )
      })
    })
  })

  it("supports multiple telescope file results", () => {
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      cy.contains("Find files")

      // The search should be open and started from the root of the project.
      // Narrow it down to some known files
      cy.typeIntoTerminal("routes/posts.$postId/.txt")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      ).should("have.css", "color", rgbify(darkTheme.text.rgb))
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      ).should("have.css", "color", rgbify(darkTheme.text.rgb))

      // Select the files with telescope. They should have a new color after
      // this to indicate they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.typeIntoTerminal("{control+i}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      ).should("have.css", "color", rgbify(darkTheme.yellow.rgb))
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      ).should("have.css", "color", rgbify(darkTheme.yellow.rgb))

      // copy the relative path. This should close telescope
      cy.typeIntoTerminal("{control+y}")
      cy.contains("Find files").should("not.exist")

      // The relative path should be copied to the clipboard.
      cy.runLuaCode({ luaCode: `return vim.fn.getreg("z")` }).then((output) => {
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
