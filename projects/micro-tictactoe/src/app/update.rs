//! Visible changes and deferred work returned by an application action.

use crate::settings::Settings;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum AppEffect {
    NewGame,
    JoinGame,
    SaveSettings(Settings),
}

#[must_use = "Apply the redraw request and execute any returned effect"]
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct AppUpdate {
    pub redraw: bool,
    pub effect: Option<AppEffect>,
}
