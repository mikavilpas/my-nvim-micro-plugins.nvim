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
      cy.typeIntoTerminal("hello from the test") // this files this very test file

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
})
