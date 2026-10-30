//! Semantic controls shared by firmware and simulator input adapters.

use crate::ui::MenuAction;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Action {
    SelectNext,
    SelectPrevious,
    SelectItem,
    FinishEdit,
    Back,
    NextCharacter,
    PreviousCharacter,
    Increment,
    Decrement,
    DeleteCharacter,
}

impl From<Action> for MenuAction {
    fn from(action: Action) -> Self {
        match action {
            Action::SelectNext => Self::NextItem,
            Action::SelectPrevious => Self::PreviousItem,
            Action::SelectItem => Self::SelectItem,
            Action::FinishEdit => Self::FinishEdit,
            Action::Back => Self::Back,
            Action::NextCharacter => Self::NextCharacter,
            Action::PreviousCharacter => Self::PreviousCharacter,
            Action::Increment => Self::Increment,
            Action::Decrement => Self::Decrement,
            Action::DeleteCharacter => Self::DeleteCharacter,
        }
    }
}
