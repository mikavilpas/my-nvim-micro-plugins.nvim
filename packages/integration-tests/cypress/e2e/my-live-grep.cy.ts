describe("my_live_grep", () => {
  it("can grep in the project (start in normal mode)", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal(" /")
      cy.contains("main.lua").should("not.exist")

      // grep should be open and started from the root of the project.
      cy.typeIntoTerminal("hello")

      cy.contains(nvim.dir.contents["file.txt"].name)
      cy.contains("main.lua")
    })
  })

  it("can grep in the project (start in insert mode)", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      // add some text that I know is present in some files in the
      // TestDirectory
      cy.typeIntoTerminal("o")
      cy.typeIntoTerminal("hello{esc}")

      // select the word and start the search
      cy.typeIntoTerminal("viw /")

      cy.contains("main.lua").should("not.exist")
      cy.contains("main.lua")
    })
  })
})
