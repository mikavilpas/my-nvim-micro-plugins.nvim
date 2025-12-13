import { isSearchVisible } from "./utils/search-utils"

describe("finding files", () => {
  it("can find files in the entire project", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      cy.typeIntoTerminal("{downArrow}")
      isSearchVisible()

      // The search should be open and started from the root of the project.
      // search results should be visible.
      //
      // Narrow it down to the TestDirectory because the file names are
      // statically known and easier to maintain
      cy.typeIntoTerminal("routes")
      cy.contains(
        nvim.dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
    })
  })

  it("starts the search with the selected text", () => {
    cy.visit("/")
    cy.startNeovim().then((_nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")
      cy.typeIntoTerminal("ccadjacent")
      cy.typeIntoTerminal("{esc}V")

      cy.typeIntoTerminal("{downArrow}")
      isSearchVisible()

      // the file must have been found and preselected because its name is
      // unique in the project.
      //
      // text inside the file must be visible in the preview window
      cy.contains("this file is adjacent-file.txt")
    })
  })
})
