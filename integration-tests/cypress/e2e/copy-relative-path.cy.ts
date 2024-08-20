import { flavors } from "@catppuccin/palette"
import { rgbify } from "./color-utils"

const darkTheme = flavors.macchiato.colors

describe("my_copy_relative_path integrations", () => {
  it("can copy the relative path to the current telescope file search result", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      cy.contains("Find files")

      // The search should be open and started from the root of the project.
      cy.typeIntoTerminal(
        dir.contents["routes/posts.$postId/adjacent-file.txt"].name,
      )

      // the file should be selected - copy the relative path
      cy.typeIntoTerminal("{control+y}")
      cy.contains("Find files").should("not.exist")

      // the relative path should be copied to the clipboard
      cy.typeIntoTerminal(":registers{enter}")

      cy.contains("../../routes/posts.$postId/adjacent-file.txt")
    })
  })

  it("can copy the relative path to the current telescope grep search result", () => {
    //
    cy.visit("http://localhost:5173")
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
      cy.typeIntoTerminal(`V"zp`)

      cy.contains("../../../cypress/e2e/copy-relative-path.cy")

      // line numbers should be removed
      cy.contains("../../../cypress/e2e/copy-relative-path.cy:").should(
        "not.exist",
      )
    })
  })

  it("can copy the relative path to the multiple telescope grep search results", () => {
    //
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      cy.contains("Live grep in")
      cy.typeIntoTerminal("file.txt$") // this very test file

      cy.contains(dir.contents["other-subdirectory/other-sub-file.txt"].name)
      cy.contains(dir.contents["routes/posts.$postId/adjacent-file.txt"].name)

      // select the files and verify they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.contains(
        dir.contents["other-subdirectory/other-sub-file.txt"].name,
      ).should("have.css", "color", rgbify(darkTheme.yellow.rgb))

      cy.typeIntoTerminal("{control+i}")
      cy.contains("adjacent-").should(
        "have.css",
        "color",
        rgbify(darkTheme.yellow.rgb),
      )

      // copy the relative path
      cy.typeIntoTerminal("{control+y}")

      // The relative path should be copied to the clipboard. Paste it
      cy.typeIntoTerminal(`V"zp`)

      // only the file paths should be copied
      cy.contains("../../other-subdirectory/other-sub-file.txt")
      cy.contains("../../routes/posts.$postId/adjacent-file.txt")

      // line numbers should be removed
      cy.contains("../../routes/posts.$postId/adjacent-file.txt:").should(
        "not.exist",
      )
      cy.contains("../../other-subdirectory/other-sub-file.txt:").should(
        "not.exist",
      )
    })
  })

  it("supports multiple telescope file results", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      cy.contains("Find files")

      // The search should be open and started from the root of the project.
      // Narrow it down to some known files
      cy.typeIntoTerminal("routes/posts.$postId/.txt")
      cy.contains(
        dir.contents["routes/posts.$postId/adjacent-file.txt"].name,
      ).should("have.css", "color", rgbify(darkTheme.text.rgb))
      cy.contains(
        dir.contents["routes/posts.$postId/should-be-excluded-file.txt"].name,
      ).should("have.css", "color", rgbify(darkTheme.text.rgb))

      // Select the files with telescope. They should have a new color after
      // this to indicate they are selected
      cy.typeIntoTerminal("{control+i}")
      cy.contains(
        dir.contents["routes/posts.$postId/adjacent-file.txt"].name,
      ).should("have.css", "color", rgbify(darkTheme.yellow.rgb))
      cy.typeIntoTerminal("{control+i}")
      cy.contains(
        dir.contents["routes/posts.$postId/should-be-excluded-file.txt"].name,
      ).should("have.css", "color", rgbify(darkTheme.yellow.rgb))

      // copy the relative path. This should close telescope
      cy.typeIntoTerminal("{control+y}")
      cy.contains("Find files").should("not.exist")

      // the relative path should be copied to the clipboard
      cy.typeIntoTerminal("V")
      cy.typeIntoTerminal(`"zp`)

      cy.contains("../../routes/posts.$postId/adjacent-file.txt")
      cy.contains("../../routes/posts.$postId/should-be-excluded-file.txt")
    })
  })
})
