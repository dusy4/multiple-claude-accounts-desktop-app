//! SaneCode preview: the look of SaneCode, built from source.
//!
//! This is not the app. It shows where to get SaneCode (free for 2 Claude accounts) and points to
//! the PowerShell scripts in this repo for doing it by hand. MIT License. Not affiliated with Anthropic.
#![windows_subsystem = "windows"]

use rune::tok::Family;
use rune::{AppSpec, Color, Cx, El, Shadow, TextStyle, col, el, row, text};

const STORE: &str = "https://sanecode.co/store/";
const SITE: &str = "https://sanecode.co/?ref=github-preview";
const SCRIPTS: &str = "https://github.com/dusy4/multiple-claude-accounts-desktop-app#use-the-powershell-scripts-instead";

const UI: TextStyle = TextStyle::new(13.0, 400.0);
const UI_MED: TextStyle = TextStyle::new(13.0, 500.0);
const SMALL: TextStyle = TextStyle::new(12.0, 400.0);
const DISPLAY: TextStyle = TextStyle::new(28.0, 400.0).family(Family::Named("Georgia, Gelasio, Times New Roman")).lh(34.0);
const MONO: TextStyle = TextStyle::new(10.5, 600.0).family(Family::SystemMono).tracking(1.0);

#[derive(Default)]
struct State;

fn c(h: &str) -> Color { rune::color::hex(h).unwrap_or_default() }

/// One soft cloud of milk poured into the blue.
fn cloud(center: [f32; 2], radius: [f32; 2], peak: f32) -> El {
    let (milk, mist) = (c("#f6f8ff"), c("#aebdff"));
    let ease = |x: f32| x * x * (3.0 - 2.0 * x);
    let stops: Vec<(f32, Color)> = (0..14).map(|i| {
        let x = i as f32 / 13.0;
        (x, milk.mix(mist, ease(((x - 0.3) / 0.6).clamp(0.0, 1.0))).alpha(peak * (1.0 - ease(x)).powf(1.35)))
    }).collect();
    el().absolute(0.0, 0.0).w_full().h_full().radial_gradient(center, radius, stops)
}

fn tag(s: &str) -> El {
    el().px(7.0).py(3.0).radius(3.0).fill(c("#111111")).child(text(s.to_string()).font(MONO).color(Color::WHITE))
}

fn button(key: &'static str, label: &str, fill: Color, ink: Color, url: &'static str) -> El {
    el().key(key).role("link").label(label.to_string()).focusable(true)
        .h(32.0).px(14.0).center().radius(4.0).fill(fill)
        .border(1.0, if fill == Color::WHITE { c("#dddddd") } else { fill })
        .press_scale(0.98)
        .on_press_tx(move |_: &mut State, tx| { let _ = tx.open_url(url); })
        .child(text(label.to_string()).font(UI_MED).color(ink))
}

fn account(initial: &str, name: &str, color: &str) -> El {
    row().h(32.0).px(8.0).gap(9.0).center_y().radius(6.0).opacity(0.45)
        .child(el().size(20.0, 20.0).radius(10.0).fill(c(color)).center()
            .child(text(initial.to_string()).font(TextStyle::new(10.0, 600.0)).color(Color::WHITE)))
        .child(text(name.to_string()).font(UI).color(c("#10153a")))
}

fn sidebar() -> El {
    col().w(248.0).h_full().padding(12.0).gap(2.0)
        .child(row().px(6.0).py(4.0).gap(8.0).center_y()
            .child(el().size(22.0, 22.0).radius(5.0).fill(c("#1f3fff")))
            .child(text("SaneCode").font(TextStyle::new(13.0, 600.0)).color(c("#10153a")))
            .child(el().grow(1.0))
            .child(tag("PREVIEW")))
        .child(el().h(14.0))
        .child(text("Accounts").font(SMALL).color(c("#4a5384")).px(8.0).py(6.0))
        .child(account("W", "Work", "#1f3fff"))
        .child(account("P", "Personal", "#c2410c"))
        .child(account("C", "Client", "#0f766e"))
        .child(el().grow(1.0))
        .child(text("Built from source. The full app: sanecode.co").font(SMALL).color(c("#323a6b")).wrap().w_full().px(6.0).py(8.0))
}

fn card() -> El {
    col().w(560.0).padding(30.0).gap(10.0).radius(10.0).fill(Color::WHITE)
        .box_shadow(Shadow { x: 0.0, y: 20.0, blur: 60.0, spread: -8.0, color: c("#0a1a80").alpha(0.22), inset: false })
        .child(row().gap(8.0).center_y().child(el().size(8.0, 8.0).fill(c("#1f3fff"))).child(text("SANECODE").font(MONO).color(c("#1f3fff"))))
        .child(text("This build is a preview.\nThe full app is free for 2 accounts.").font(DISPLAY).color(c("#111111")))
        .child(text("This repository has the look and the PowerShell scripts. Running several Claude accounts in one window, switching without signing out and moving sessions between accounts is in SaneCode.").font(UI.lh(21.0)).color(c("#666666")).wrap().w_full())
        .child(el().h(8.0))
        .child(row().gap(8.0).flex_wrap().w_full()
            .child(button("store", "Get it from Microsoft Store", c("#1f3fff"), Color::WHITE, STORE))
            .child(button("site", "Download from sanecode.co", c("#111111"), Color::WHITE, SITE))
            .child(button("scripts", "Use the PowerShell scripts instead", Color::WHITE, c("#111111"), SCRIPTS)))
}

fn view(_: &State, _: &mut Cx<State>) -> El {
    let ground = el().absolute(0.0, 0.0).w_full().h_full().fill(c("#1f3fff"))
        .linear_gradient(2.4, [(0.0, c("#3b5bff")), (0.5, c("#1f3fff")), (1.0, c("#1733d6"))])
        .child(cloud([-0.1, 0.5], [520.0, 1000.0], 1.0))
        .child(cloud([0.0, -0.08], [700.0, 500.0], 0.95))
        .child(cloud([0.48, -0.32], [720.0, 360.0], 0.55));
    row().w_full().h_full()
        .child(ground)
        .child(sidebar())
        .child(col().grow(1.0).h_full().center().gap(14.0)
            .child(row().gap(8.0).child(tag("OPEN SOURCE PREVIEW")).child(tag("ACCOUNTS: 0")))
            .child(card()))
}

fn main() {
    rune::run(AppSpec::<State> { ..AppSpec::new("SaneCode preview", (1180.0, 760.0), State::default, view) });
}
