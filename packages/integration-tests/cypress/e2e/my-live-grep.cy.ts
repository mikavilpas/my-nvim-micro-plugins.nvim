describe("my_live_grep", () => {
  it("can grep in the project (start in normal mode)", () => {
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")

      // telescope grep should be open and started from the root of the
      // project.
      cy.typeIntoTerminal("hello")

      cy.contains(dir.contents["file.txt"].name)
      cy.contains(
        dir.contents.subdirectory.contents["subdirectory-file.txt"].name,
      )
    })
  })

  it("can grep in the project (start in insert mode)", () => {
    cy.visit("/")
    cy.startNeovim().then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // add some text that I know is present in some files in the
      // TestDirectory
      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("hello{esc}")

      // select the word and start the search
      cy.typeIntoTerminal("viw /")

      cy.contains(
        dir.contents.subdirectory.contents["subdirectory-file.txt"].name,
      )
    })
  })
})
