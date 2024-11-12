describe("telescope integration", () => {
  it("can find files in the entire project", () => {
    cy.visit("/")
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
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
    })
  })
})
