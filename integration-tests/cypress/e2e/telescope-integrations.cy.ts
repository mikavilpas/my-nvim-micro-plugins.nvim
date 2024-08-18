describe("telescope integration", () => {
  it("can find files in the entire project", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      cy.contains("Find files")

      // The search should be open and started from the root of the project.
      // search results should be visible.
      //
      // Narrow it down to the TestDirectory because the file names are
      // statically known and easier to maintain
      cy.typeIntoTerminal("routes")
      cy.contains(dir.contents["routes/posts.$postId/adjacent-file.txt"].name)
    })
  })

  describe("my_live_grep", () => {
    it("can grep in the project (start in normal mode)", () => {
      cy.visit("http://localhost:5173")
      cy.startNeovim().then((dir) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")

        cy.typeIntoTerminal(" /")

        // telescope grep should be open and started from the root of the
        // project.
        cy.typeIntoTerminal("hello")

        cy.contains(dir.contents["file.txt"].name)
        cy.contains(dir.contents["subdirectory/subdirectory-file.txt"].name)
      })
    })

    it("can grep in the project (start in insert mode)", () => {
      cy.visit("http://localhost:5173")
      cy.startNeovim().then((dir) => {
        // wait until text on the start screen is visible
        cy.contains("If you see this text, Neovim is ready!")

        // add some text that I know is present in some files in the
        // TestDirectory
        cy.typeIntoTerminal("o")
        cy.typeIntoTerminal("hello{esc}")

        // select the word and start the search
        cy.typeIntoTerminal("viw /")

        cy.contains(dir.contents["subdirectory/subdirectory-file.txt"].name)
      })
    })
  })

  describe("my_copy_relative_path", () => {
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
  })
})
