#!/usr/bin/env python3
"""Generate documents/architecture.drawio — visual architecture diagrams (boxes + arrows)."""

from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "documents" / "architecture.drawio"


def box(fill, stroke, font="#263238", size=12, sw=1.5):
    return (
        f"rounded=1;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
        f"strokeWidth={sw};fontSize={size};fontStyle=1;fontColor={font};"
        f"align=center;verticalAlign=middle;arcSize=12;"
    )


def circle(fill, stroke, font="#263238", size=11):
    return (
        f"ellipse;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
        f"strokeWidth=1.5;fontSize={size};fontStyle=1;fontColor={font};"
        f"align=center;verticalAlign=middle;"
    )


def lane(fill, stroke, font="#37474F"):
    return (
        f"swimlane;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
        f"strokeWidth=2;fontStyle=1;startSize=36;fontSize=14;fontColor={font};"
        f"align=center;arcSize=8;"
    )


def step_box():
    return (
        "rounded=1;whiteSpace=wrap;html=1;fillColor=#37474F;strokeColor=#263238;"
        "strokeWidth=1;fontSize=11;fontStyle=1;fontColor=#FFFFFF;"
        "align=center;verticalAlign=middle;arcSize=8;"
    )


def col_header(fill):
    return (
        f"rounded=0;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={fill};"
        f"fontSize=12;fontStyle=1;fontColor=#FFFFFF;align=center;verticalAlign=middle;"
    )


def lifeline():
    return (
        "endArrow=none;html=1;dashed=1;dashPattern=8 8;strokeColor=#B0BEC5;"
        "strokeWidth=2;exitX=0.5;exitY=1;entryX=0.5;entryY=0;"
    )


class SeqChart:
    """Swimlane sequence: columns + numbered steps top-to-bottom (no crossing arrows)."""

    def __init__(self, page, columns, x0=160, y0=90, col_w=220, header_h=52, row_h=72, gap=14):
        self.p = page
        self.columns = columns  # [(title, header_fill), ...]
        self.x0 = x0
        self.y0 = y0
        self.col_w = col_w
        self.header_h = header_h
        self.row_h = row_h
        self.gap = gap
        self.y = y0 + header_h + 24
        self.headers = []
        self.n = 0
        for i, (title, fill) in enumerate(columns):
            x = x0 + i * col_w
            hid = page.cell(col_header(fill), title, x + 6, y0, col_w - 12, header_h)
            self.headers.append(hid)
            page.cell(
                "rounded=0;fillColor=none;strokeColor=#B0BEC5;dashed=1;"
                "dashPattern=8 8;strokeWidth=2;",
                "",
                x + col_w / 2 - 1,
                y0 + header_h,
                2,
                1400,
            )

    def col_x(self, i):
        return self.x0 + i * self.col_w + 10

    def col_w_inner(self):
        return self.col_w - 20

    def step(self, col, title, detail=""):
        self.n += 1
        text = f"{self.n}. {title}"
        if detail:
            text += f"\n{detail}"
        cid = self.p.cell(
            step_box(),
            text,
            self.col_x(col),
            self.y,
            self.col_w_inner(),
            self.row_h,
        )
        self.y += self.row_h + self.gap
        return cid

    def phase(self, label, y_start, y_end):
        h = max(48, y_end - y_start)
        self.p.cell(
            "rounded=1;whiteSpace=wrap;html=1;fillColor=#CFD8DC;strokeColor=#90A4AE;"
            "fontSize=10;fontStyle=1;fontColor=#37474F;align=center;verticalAlign=middle;"
            "horizontal=0;",
            label,
            20,
            y_start,
            44,
            h,
        )

    def finish_lifelines(self):
        return


def title_style():
    return "text;html=1;align=left;fontSize=22;fontStyle=1;fontColor=#212121;"


def legend_style():
    return "text;html=1;align=left;fontSize=11;fontColor=#546E7A;"


# Arrows — match the two reference diagrams
A_ACTION = (
    "endArrow=block;endFill=1;html=1;strokeWidth=2;strokeColor=#7E57C2;"
    "fontSize=11;fontColor=#7E57C2;fontStyle=1;"
)
A_DATA = (
    "endArrow=open;dashed=1;html=1;strokeWidth=1.5;strokeColor=#9E9E9E;"
    "fontSize=11;fontColor=#757575;fontStyle=1;"
)
A_IMPORT = (
    "endArrow=block;endFill=1;html=1;strokeWidth=1.5;strokeColor=#212121;"
    "fontSize=11;fontColor=#212121;fontStyle=1;"
)
A_INHERIT = (
    "endArrow=block;endFill=0;html=1;strokeWidth=2;strokeColor=#43A047;"
    "fontSize=11;fontColor=#2E7D32;fontStyle=1;"
)
A_DEP = (
    "endArrow=block;endFill=1;html=1;strokeWidth=5;strokeColor=#7E57C2;"
    "fontSize=12;fontStyle=1;fontColor=#7E57C2;"
)
A_ORTHO = "edgeStyle=orthogonalEdgeStyle;rounded=1;"


class Page:
    def __init__(self, pid, name, w=1600, h=1000):
        self.pid = pid
        self.name = name
        self.w = w
        self.h = h
        self.cells = []
        self.n = 0

    def _id(self):
        self.n += 1
        return f"{self.pid}_{self.n}"

    def cell(self, style, value, x, y, w, h, parent="1"):
        cid = self._id()
        val = escape(value, {'"': "&quot;"}).replace("\n", "&#xa;")
        self.cells.append(
            f'        <mxCell id="{cid}" parent="{parent}" style="{style}" '
            f'value="{val}" vertex="1">\n'
            f'          <mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry" />\n'
            f"        </mxCell>"
        )
        return cid

    def edge(self, source, target, style, label="", parent="1", exit=None, entry=None):
        cid = self._id()
        val = escape(label, {'"': "&quot;"}).replace("\n", "&#xa;") if label else ""
        if "edgeStyle" not in style:
            style = style + ";edgeStyle=orthogonalEdgeStyle"
        style = style + ";rounded=0;orthogonalLoop=1"
        if exit:
            style += f";exitX={exit[0]};exitY={exit[1]};exitDx=0;exitDy=0"
        if entry:
            style += f";entryX={entry[0]};entryY={entry[1]};entryDx=0;entryDy=0"
        self.cells.append(
            f'        <mxCell id="{cid}" parent="{parent}" source="{source}" target="{target}" '
            f'edge="1" style="{style}" value="{val}">\n'
            f'          <mxGeometry relative="1" as="geometry" />\n'
            f"        </mxCell>"
        )
        return cid

    def xml(self):
        body = "\n".join(self.cells)
        return f"""  <diagram id="{self.pid}" name="{escape(self.name)}">
    <mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{self.w}" pageHeight="{self.h}" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
{body}
      </root>
    </mxGraphModel>
  </diagram>"""


# Palette from the two reference images
BLUE, BLUE_S = "#5B9BD5", "#2E75B6"
GREEN, GREEN_S = "#8BC34A", "#558B2F"
RED, RED_S = "#EF9A9A", "#C62828"
GOLD, GOLD_S = "#FFD54F", "#F9A825"
LIME, LIME_S = "#AED581", "#7CB342"
NAVY = "#FFFFFF"


def build():
    pages = []

    # ══════════════════════════════════════════════════════════════
    # 01  Project Architecture  (style of image 2)
    # ══════════════════════════════════════════════════════════════
    p = Page("p01", "01 - Project Architecture", 1680, 1200)
    p.cell(title_style(), "Project Architecture", 40, 16, 700, 36)
    p.cell(
        legend_style(),
        "mũi tên xanh lá viền rỗng = Inherit     mũi tên đen = Import",
        40,
        52,
        900,
        24,
    )
    lg1 = p.cell(box("#E8F5E9", "#43A047", size=10), "Inherit", 1100, 16, 90, 32)
    lg2 = p.cell(box("#EEEEEE", "#212121", size=10), "Import", 1280, 16, 90, 32)
    p.edge(lg1, lg2, A_INHERIT, "Inherit", exit=(1, 0.5), entry=(0, 0.5))

    init_l = p.cell(lane("#CFD8DC", "#607D8B"), "Initializer", 560, 80, 540, 120)
    init = p.cell(
        box("#ECEFF1", "#546E7A"),
        "bootstrap · GetIt · plugPackages",
        30,
        48,
        480,
        52,
        parent=init_l,
    )

    # 3 lane cùng y → hàng nội dung thẳng hàng
    app_l = p.cell(lane("#BBDEFB", "#1565C0", "#0D47A1"), "App  (Presentation)", 40, 220, 500, 540)
    dom_l = p.cell(lane("#FFE0B2", "#EF6C00", "#E65100"), "Domain + Core gateways", 560, 220, 540, 540)
    data_l = p.cell(lane("#FFCDD2", "#C62828", "#B71C1C"), "Data", 1120, 220, 520, 540)

    # Hàng 1
    main = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "main() → bootstrap()", 20, 48, 220, 52, parent=app_l)
    overlay = p.cell(
        box("#4DB6AC", "#00695C", "#FFFFFF"),
        "OverlayHost · OverlayScope",
        260,
        48,
        220,
        52,
        parent=app_l,
    )
    dcfg = p.cell(box("#FFE0B2", "#EF6C00"), "AppConfig  (core)", 20, 48, 240, 52, parent=dom_l)
    abs_repo = p.cell(circle(RED, RED_S, "#FFFFFF", size=10), "Abstract Repository", 280, 40, 240, 68, parent=dom_l)
    repo_i = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "Repository Impl", 20, 48, 480, 52, parent=data_l)

    # Hàng 2 — Router | Session | Interceptor (một đường ngang)
    router = p.cell(
        box("#42A5F5", "#1565C0", "#FFFFFF"),
        "GoRouter + RoutePolicy",
        260,
        128,
        220,
        56,
        parent=app_l,
    )
    abs_sess = p.cell(
        circle("#E57373", "#C62828", "#FFFFFF", size=10),
        "Session (core)\nstatus · authorizationHeaders",
        20,
        116,
        500,
        80,
        parent=dom_l,
    )
    interceptor = p.cell(
        box("#FFB74D", "#EF6C00", "#FFFFFF"),
        "Interceptor  ·  Auth · Log · Idempotency",
        20,
        128,
        480,
        56,
        parent=data_l,
    )

    # Hàng 3
    ui = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "AppScaffold", 20, 216, 220, 52, parent=app_l)
    bloc = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "BLoC · OverlayFeedback", 260, 216, 220, 52, parent=app_l)
    abs_nav = p.cell(
        circle("#FF8A65", "#E64A19", "#FFFFFF", size=10),
        "RoutePolicy  public | guest | authRequired",
        20,
        216,
        500,
        52,
        parent=dom_l,
    )
    api_ds = p.cell(box(LIME, LIME_S), "Chopper API · Network DS", 20, 216, 230, 52, parent=data_l)
    cache_ds = p.cell(box(LIME, LIME_S), "DataGateway\nCache + Outbox", 270, 216, 230, 52, parent=data_l)

    # Hàng 4
    theme = p.cell(box("#90CAF9", "#1565C0"), "Theme · FormScope · validators", 20, 292, 460, 52, parent=app_l)
    usecase = p.cell(box(RED, RED_S, "#FFFFFF"), "Use Case", 20, 292, 240, 52, parent=dom_l)
    entity = p.cell(box(GOLD, GOLD_S), "Entity", 280, 292, 240, 52, parent=dom_l)
    api = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "ApiClient\n+ Fake | HTTP transport", 20, 292, 230, 52, parent=data_l)
    db = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "MemoryCacheStore", 270, 292, 230, 52, parent=data_l)

    p.edge(main, overlay, A_IMPORT, "bọc", parent=app_l, exit=(1, 0.5), entry=(0, 0.5))
    p.edge(main, ui, A_IMPORT, "tạo", parent=app_l, exit=(0.5, 1), entry=(0.5, 0))
    p.edge(main, router, A_IMPORT, "gắn", parent=app_l, exit=(1, 1), entry=(0, 0.5))
    p.edge(ui, bloc, A_IMPORT, "add Event", parent=app_l, exit=(1, 0.5), entry=(0, 0.5))

    p.edge(usecase, entity, A_IMPORT, "dùng", parent=dom_l, exit=(1, 0.5), entry=(0, 0.5))
    p.edge(usecase, abs_repo, A_IMPORT, "gọi", parent=dom_l, exit=(0.8, 0), entry=(0.5, 1))

    p.edge(repo_i, api_ds, A_IMPORT, "dùng", parent=data_l, exit=(0.25, 1), entry=(0.5, 0))
    p.edge(repo_i, cache_ds, A_IMPORT, "dùng", parent=data_l, exit=(0.75, 1), entry=(0.5, 0))
    p.edge(api_ds, api, A_IMPORT, "gửi request", parent=data_l, exit=(0.5, 1), entry=(0.5, 0))
    p.edge(interceptor, api, A_IMPORT, "bọc client", parent=data_l, exit=(0.25, 1), entry=(0.5, 0))
    p.edge(cache_ds, db, A_IMPORT, "đọc / ghi", parent=data_l, exit=(0.5, 1), entry=(0.5, 0))

    p.edge(init, main, A_IMPORT, "setup", exit=(0, 0.5), entry=(0.5, 0))
    p.edge(bloc, usecase, A_IMPORT, "gọi", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(repo_i, abs_repo, A_INHERIT, "implements", exit=(0, 0.5), entry=(1, 0.5))
    p.edge(router, abs_sess, A_IMPORT, "đọc status", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(interceptor, abs_sess, A_IMPORT, "authorizationHeaders", exit=(0, 0.5), entry=(1, 0.5))
    p.edge(router, abs_nav, A_IMPORT, "đọc policy", exit=(0.5, 1), entry=(0, 0.5))

    res_l = p.cell(lane("#C8E6C9", "#2E7D32", "#1B5E20"), "Resources", 40, 790, 500, 150)
    p.cell(box("#A5D6A7", "#2E7D32"), "l10n  .arb", 20, 48, 220, 52, parent=res_l)
    p.cell(box("#A5D6A7", "#2E7D32"), "assets · icons", 260, 48, 220, 52, parent=res_l)
    p.edge(theme, res_l, A_IMPORT, "import", exit=(0.5, 1), entry=(0.5, 0))

    sh_l = p.cell(lane("#E1BEE7", "#8E24AA", "#6A1B9A"), "Shared / Core", 560, 790, 540, 150)
    p.cell(
        box("#CE93D8", "#8E24AA", "#FFFFFF", size=11),
        "Result · RequestPolicy · LogSink · PushService · OverlayFeedback",
        20,
        48,
        500,
        52,
        parent=sh_l,
    )
    p.edge(dom_l, sh_l, A_IMPORT, "import", exit=(0.5, 1), entry=(0.5, 0))

    pkg_l = p.cell(lane("#F3E5F5", "#8E24AA", "#6A1B9A"), "Packages  (opt-in qua pubspec)", 1120, 790, 520, 150)
    p.cell(
        box("#CE93D8", "#8E24AA", "#FFFFFF", size=11),
        "composable_auth · log · push",
        20,
        48,
        480,
        52,
        parent=pkg_l,
    )
    p.edge(pkg_l, interceptor, A_INHERIT, "cắm impl", exit=(0.5, 0), entry=(0.5, 1))

    p.cell(
        legend_style(),
        "Hàng 2: GoRouter → Session.status ← Interceptor.authorizationHeaders. Use Case không đọc Session. Token không nằm trên SessionState.",
        40,
        960,
        1600,
        28,
    )
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 02  Clean Architecture + BLoC  (style of image 1)
    # ══════════════════════════════════════════════════════════════
    p = Page("p02", "02 - Clean Architecture + BLoC", 1600, 980)
    p.cell(title_style(), "Clean Architecture + BLoC  —  trong một feature", 40, 16, 1200, 36)
    p.cell(legend_style(), "mũi tên tím đặc = gọi / phụ thuộc · nét đứt xám = data trả về", 40, 50, 900, 22)

    pres = p.cell(lane("#FAFAFA", "#9E9E9E"), "Presentation", 40, 90, 460, 680)
    event = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "Event", 150, 60, 160, 50, parent=pres)
    view = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "View", 40, 200, 150, 70, parent=pres)
    bloc = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "BLoC", 250, 200, 160, 70, parent=pres)
    state = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "State", 150, 360, 160, 50, parent=pres)
    p.edge(view, event, A_ACTION + A_ORTHO, "add", parent=pres)
    p.edge(event, bloc, A_ACTION + A_ORTHO, "xử lý", parent=pres)
    p.edge(bloc, state, A_DATA + A_ORTHO, "emit", parent=pres)
    p.edge(state, view, A_DATA + A_ORTHO, "rebuild", parent=pres)
    ov = p.cell(box("#4DB6AC", "#00695C", "#FFFFFF", size=11), "OverlayFeedback\n(toast / loading)", 40, 480, 380, 56, parent=pres)
    p.edge(bloc, ov, A_DATA + A_ORTHO, "ISP — không OverlayController", parent=pres)

    domain = p.cell(lane("#FAFAFA", "#9E9E9E"), "Domain", 540, 90, 420, 680)
    repo_if = p.cell(circle(RED, RED_S, "#FFFFFF"), "Repository\n(interface)", 130, 50, 160, 100, parent=domain)
    uc = p.cell(box(RED, RED_S, "#FFFFFF"), "Use Case", 120, 200, 180, 70, parent=domain)
    ent = p.cell(box(GOLD, GOLD_S), "Entity", 120, 360, 180, 60, parent=domain)
    p.edge(uc, repo_if, A_ACTION, "gọi", parent=domain)
    p.edge(repo_if, uc, A_DATA + A_ORTHO, "Result", parent=domain)
    p.edge(uc, ent, A_ACTION, "dùng", parent=domain)
    p.edge(ent, uc, A_DATA + A_ORTHO, "data", parent=domain)

    data = p.cell(lane("#FAFAFA", "#9E9E9E"), "Data", 1000, 90, 560, 680)
    repo = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "Repository Impl", 180, 70, 200, 56, parent=data)
    ds_if = p.cell(circle(LIME, LIME_S), "DataGateway\n(RequestPolicy)", 180, 170, 200, 90, parent=data)
    net = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "Chopper API\nAuthApi · FeedApi", 40, 300, 180, 70, parent=data)
    cache = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "CacheStore\n+ Outbox (RAM)", 340, 300, 180, 70, parent=data)
    api = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "ApiClient\nFake | HTTP", 40, 430, 180, 56, parent=data)
    db = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "MemoryCacheStore", 340, 430, 180, 56, parent=data)
    p.edge(repo, ds_if, A_ACTION, "gọi", parent=data)
    p.edge(ds_if, net, A_ACTION + A_ORTHO, "remote", parent=data)
    p.edge(ds_if, cache, A_ACTION + A_ORTHO, "local", parent=data)
    p.edge(net, api, A_ACTION, "HTTP", parent=data)
    p.edge(cache, db, A_ACTION, "đọc / ghi", parent=data)
    p.edge(api, net, A_DATA + A_ORTHO, "response", parent=data)
    p.edge(db, cache, A_DATA + A_ORTHO, "data", parent=data)
    p.edge(net, ds_if, A_DATA + A_ORTHO, "DTO", parent=data)
    p.edge(cache, ds_if, A_DATA + A_ORTHO, "DTO", parent=data)

    # Cross layer
    p.edge(bloc, uc, A_ACTION, "gọi")
    p.edge(uc, bloc, A_DATA + A_ORTHO, "Result")
    p.edge(repo, repo_if, A_INHERIT, "implements")
    p.edge(repo_if, repo, A_DATA + A_ORTHO, "data")

    # Dependency rule
    p.cell(box("#EDE7F6", "#7E57C2", "#7E57C2", size=14), "Dependency Rule", 200, 800, 220, 44)
    p.edge(pres, domain, A_DEP, "phụ thuộc")
    p.edge(data, domain, A_DEP, "phụ thuộc")
    p.cell(legend_style(), "Presentation và Data phụ thuộc Domain. Domain không biết Flutter, HTTP, Overlay, Session.", 40, 860, 1400, 28)
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 03  Overlay + Shell runtime
    # ══════════════════════════════════════════════════════════════
    p = Page("p03", "03 - Overlay + Shell", 1600, 1040)
    p.cell(title_style(), "Runtime — OverlayHost bọc router, che cả tab", 40, 16, 1200, 36)
    p.cell(
        legend_style(),
        "Z-order dưới → trên: child → banner → toast → block → loading → tutorial. OverlayScope cho AppScaffold. BLoC chỉ OverlayFeedback.",
        40,
        50,
        1400,
        22,
    )

    host = p.cell(lane("#E0F2F1", "#00897B", "#00695C"), "OverlayHost  (OverlayScope)", 480, 90, 640, 720)
    tut = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "Tutorial / Onboarding", 40, 52, 560, 48, parent=host)
    load = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "Loading  (full-screen + slot giữa)", 40, 120, 560, 48, parent=host)
    block = p.cell(box("#EF9A9A", "#C62828", "#FFFFFF"), "No-internet  BLOCK", 40, 188, 560, 48, parent=host)
    toast = p.cell(box("#FFE082", "#F9A825"), "ToastQueue  (max 5, dedupe)", 40, 256, 560, 48, parent=host)
    banner = p.cell(box("#FFF59D", "#FBC02D"), "No-internet  BANNER", 40, 324, 560, 48, parent=host)
    go = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "GoRouter", 40, 400, 560, 52, parent=host)
    splash = p.cell(box("#90CAF9", "#1565C0"), "Splash", 40, 480, 120, 48, parent=host)
    login = p.cell(box("#90CAF9", "#1565C0"), "Login", 170, 480, 100, 48, parent=host)
    forgot = p.cell(box("#90CAF9", "#1565C0"), "Forgot", 280, 480, 90, 48, parent=host)
    shell = p.cell(box("#42A5F5", "#1565C0", "#FFFFFF"), "StatefulShell\nFeed · Profile", 390, 472, 210, 64, parent=host)
    home = p.cell(box("#BBDEFB", "#1565C0"), "Feed /home", 390, 560, 100, 44, parent=host)
    prof = p.cell(box("#BBDEFB", "#1565C0"), "Profile", 500, 560, 100, 44, parent=host)
    p.edge(go, splash, A_IMPORT + A_ORTHO, "route", parent=host)
    p.edge(go, login, A_IMPORT + A_ORTHO, "route", parent=host)
    p.edge(go, forgot, A_IMPORT + A_ORTHO, "route", parent=host)
    p.edge(go, shell, A_IMPORT + A_ORTHO, "route", parent=host)
    p.edge(shell, home, A_IMPORT, "tab", parent=host)
    p.edge(shell, prof, A_IMPORT, "tab", parent=host)

    # Left: who talks to host
    left = p.cell(lane("#E3F2FD", "#1565C0", "#0D47A1"), "Ai gọi host", 40, 90, 400, 400)
    sc = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "AppScaffold\nOverlayScope.of", 24, 56, 352, 64, parent=left)
    bl = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "BLoC → OverlayFeedback", 24, 148, 352, 56, parent=left)
    conn = p.cell(box("#26A69A", "#00695C", "#FFFFFF"), "ConnectivityHint", 24, 232, 352, 56, parent=left)
    p.edge(sc, host, A_ACTION, "PageConfig")
    p.edge(bl, load, A_ACTION, "push / pop")
    p.edge(bl, toast, A_ACTION, "showToast")
    p.edge(conn, banner, A_DATA + A_ORTHO, "offline")
    p.edge(conn, block, A_DATA + A_ORTHO, "offline")

    # Right: PageConfig
    right = p.cell(lane("#FFF8E1", "#F9A825", "#E65100"), "PageConfig", 1160, 90, 400, 400)
    p.cell(box("#EEEEEE", "#9E9E9E"), "inherit", 24, 56, 352, 48, parent=right)
    p.cell(box("#FFF59D", "#FBC02D"), "banner", 24, 120, 352, 48, parent=right)
    p.cell(box("#EF9A9A", "#C62828", "#FFFFFF"), "block", 24, 184, 352, 48, parent=right)
    p.cell(box("#FAFAFA", "#BDBDBD"), "off", 24, 248, 352, 48, parent=right)
    p.cell(box("#90CAF9", "#1565C0", size=11), "/checkout  authRequired (mẫu)", 24, 312, 352, 48, parent=right)

    p.cell(box("#E8F5E9", "#2E7D32"), "First load → Skeleton (trong body, không overlay)", 40, 860, 520, 56)
    p.cell(box("#FFF3E0", "#EF6C00"), "Submit / login → Loading overlay", 580, 860, 480, 56)
    p.cell(box("#E3F2FD", "#1565C0"), "Refresh nền → không che màn", 1080, 860, 480, 56)
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 04  Network + Offline
    # ══════════════════════════════════════════════════════════════
    p = Page("p04", "04 - Network Cache Offline", 1600, 1020)
    p.cell(title_style(), "Network · Cache · Offline — DataGateway + RequestPolicy", 40, 16, 1300, 36)
    p.cell(
        legend_style(),
        "Policy gắn trên từng request. CacheStore + Outbox nằm trong core (Memory*). Transport = Fake khi apiBaseUrl rỗng, HTTP khi có URL.",
        40,
        50,
        1500,
        22,
    )

    uc = p.cell(box(RED, RED_S, "#FFFFFF"), "Use Case", 40, 120, 180, 64)
    repo = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "Repository Impl", 280, 120, 200, 64)
    p.edge(uc, repo, A_ACTION, "gọi")

    # three branches
    read = p.cell(lane("#E3F2FD", "#1565C0", "#0D47A1"), "1. Đọc  (DataGateway.read)", 40, 240, 480, 520)
    cf = p.cell(box(GOLD, GOLD_S), "cacheFirst /\nstale-while-revalidate", 24, 56, 432, 56, parent=read)
    cds = p.cell(box(LIME, LIME_S), "MemoryCacheStore", 24, 140, 200, 56, parent=read)
    nds1 = p.cell(box(LIME, LIME_S), "ApiClient.send", 256, 140, 200, 56, parent=read)
    db1 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "RAM cache", 24, 230, 200, 48, parent=read)
    api1 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "Fake | HTTP", 256, 230, 200, 48, parent=read)
    p.edge(cf, cds, A_ACTION, "hit?", parent=read)
    p.edge(cf, nds1, A_ACTION, "fetch", parent=read)
    p.edge(cds, db1, A_ACTION, "đọc", parent=read)
    p.edge(nds1, api1, A_ACTION, "HTTP", parent=read)

    write = p.cell(lane("#FFF3E0", "#EF6C00", "#E65100"), "2. Queue ghi  (MemoryOutbox)", 560, 240, 480, 520)
    pol2 = p.cell(box(GOLD, GOLD_S), "retryOnReconnect\n+ idempotencyKey", 24, 56, 432, 56, parent=write)
    ob = p.cell(box(LIME, LIME_S), "MemoryOutbox", 24, 140, 432, 56, parent=write)
    drain = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "Drain  (concurrency 1)", 24, 220, 432, 48, parent=write)
    api2 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "ApiClient.send", 24, 300, 432, 48, parent=write)
    p.edge(pol2, ob, A_ACTION, "enqueue", parent=write)
    p.edge(ob, drain, A_ACTION, "khi online", parent=write)
    p.edge(drain, api2, A_ACTION, "HTTP", parent=write)

    inflight = p.cell(lane("#FFEBEE", "#C62828", "#B71C1C"), "3. Drop giữa chừng", 1080, 240, 480, 520)
    drop = p.cell(box("#EF9A9A", "#C62828", "#FFFFFF"), "mất mạng mid-request", 24, 56, 432, 56, parent=inflight)
    q = p.cell(circle(GOLD, GOLD_S), "GET  hoặc\ncó idempotency?", 140, 140, 200, 100, parent=inflight)
    yes = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "retry / queue", 24, 280, 200, 48, parent=inflight)
    no = p.cell(box(RED, RED_S, "#FFFFFF"), "Err → UI", 256, 280, 200, 48, parent=inflight)
    p.edge(drop, q, A_ACTION, "kiểm tra", parent=inflight)
    p.edge(q, yes, A_ACTION, "yes", parent=inflight)
    p.edge(q, no, A_ACTION, "no", parent=inflight)

    decode = p.cell(box("#4DB6AC", "#00695C", "#FFFFFF"), "SafeDecode\nparse fail = không retry", 520, 112, 240, 80)
    p.edge(repo, decode, A_DATA + A_ORTHO, "parse")

    p.edge(repo, cf, A_ACTION + A_ORTHO, "GET")
    p.edge(repo, pol2, A_ACTION + A_ORTHO, "ghi")
    p.edge(repo, drop, A_ACTION + A_ORTHO, "in-flight")
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 05  Auth + Router
    # ══════════════════════════════════════════════════════════════
    p = Page("p05", "05 - Auth + Router", 1600, 1000)
    p.cell(title_style(), "Session ghi — Router đọc status — Interceptor gắn header", 40, 16, 1300, 36)
    p.cell(
        legend_style(),
        "SessionState chỉ status. Token trong AuthService/StubSession + TokenVault. handshakePaths (login/refresh) không refresh/kick.",
        40,
        50,
        1500,
        22,
    )

    sess_l = p.cell(lane("#FFCDD2", "#C62828", "#B71C1C"), "Session  (AuthService | StubSession)", 40, 90, 720, 420)
    unk = p.cell(box("#B0BEC5", "#546E7A", "#FFFFFF"), "unknown", 24, 70, 150, 56, parent=sess_l)
    gst = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "guest", 200, 70, 150, 56, parent=sess_l)
    una = p.cell(box(GOLD, GOLD_S), "unauthenticated", 376, 70, 170, 56, parent=sess_l)
    aut = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "authenticated", 560, 70, 140, 56, parent=sess_l)
    p.edge(unk, gst, A_ACTION, "guestAllowed", parent=sess_l)
    p.edge(unk, una, A_ACTION + A_ORTHO, "authRequired", parent=sess_l)
    p.edge(unk, aut, A_ACTION + A_ORTHO, "token ok", parent=sess_l)
    tok = p.cell(box("#ECEFF1", "#546E7A"), "TokenVault (package)\ntokens không trên State", 24, 200, 320, 64, parent=sess_l)
    rf = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "refresh()\nsingle-flight", 376, 200, 324, 64, parent=sess_l)

    rtr_l = p.cell(lane("#BBDEFB", "#1565C0", "#0D47A1"), "GoRouter.redirect  +  RoutePolicy", 800, 90, 760, 420)
    p.cell(box(BLUE, BLUE_S, "#FFFFFF", size=11), "unknown  →  /splash", 24, 56, 712, 48, parent=rtr_l)
    p.cell(box("#90CAF9", "#1565C0", size=11), "cần auth + unauth  →  /login?from=", 24, 120, 712, 48, parent=rtr_l)
    p.cell(box("#90CAF9", "#1565C0", size=11), "guest + /checkout  →  /login", 24, 184, 712, 48, parent=rtr_l)
    p.cell(box(GREEN, GREEN_S, "#FFFFFF", size=11), "authenticated + /login  →  /home", 24, 248, 712, 48, parent=rtr_l)
    p.edge(sess_l, rtr_l, A_DATA, "state.status")

    # 401 flow
    p.cell(lane("#FFF3E0", "#EF6C00", "#E65100"), "401 → handshake skip · refresh · kick?", 40, 540, 1520, 360)
    a401 = p.cell(box("#EF9A9A", "#C62828", "#FFFFFF"), "401", 80, 600, 120, 56)
    off = p.cell(circle(GOLD, GOLD_S), "offline?\nor handshake?", 260, 584, 150, 88)
    keep = p.cell(box("#B0BEC5", "#546E7A", "#FFFFFF"), "giữ session\n(login/refresh/offline)", 480, 600, 200, 56)
    rfs = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "refresh()", 760, 600, 140, 56)
    ok = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "retry + headers", 960, 540, 180, 56)
    kick = p.cell(box(RED, RED_S, "#FFFFFF"), "kick\n→ unauth → /login", 960, 660, 200, 64)
    netfail = p.cell(box("#B0BEC5", "#546E7A", "#FFFFFF"), "mạng/5xx\nkhông kick", 1240, 600, 180, 56)
    p.edge(a401, off, A_ACTION, "401")
    p.edge(off, keep, A_ACTION, "yes")
    p.edge(off, rfs, A_ACTION, "no")
    p.edge(rfs, ok, A_ACTION + A_ORTHO, "ok")
    p.edge(rfs, kick, A_ACTION + A_ORTHO, "AuthFailure")
    p.edge(rfs, netfail, A_ACTION, "false")
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 06  Cửa ngõ + packages
    # ══════════════════════════════════════════════════════════════
    p = Page("p06", "06 - Cửa ngõ + Packages", 1600, 1000)
    p.cell(title_style(), "Bốn cửa ngõ — package cắm vào, không tự bootstrap", 40, 16, 1200, 36)
    p.cell(legend_style(), "▲ Inherit = implement interface     → Import = dùng     Cắm/dùng: tab 06b", 40, 50, 1100, 22)

    core = p.cell(lane("#E3F2FD", "#1565C0", "#0D47A1"), "App core  —  luôn có", 40, 90, 1520, 280)
    g1 = p.cell(box("#4DB6AC", "#00695C", "#FFFFFF"), "OverlayHost\nOverlayFeedback", 40, 56, 320, 80, parent=core)
    g2 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "Router\nGoRouter + RoutePolicy", 400, 56, 320, 80, parent=core)
    g3 = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "RequestPolicy\n+ ApiClient + DataGateway", 760, 56, 340, 80, parent=core)
    g4 = p.cell(circle(RED, RED_S, "#FFFFFF"), "Session\n(interface)", 1140, 40, 320, 110, parent=core)

    pkgs = p.cell(lane("#F3E5F5", "#8E24AA", "#6A1B9A"), "Packages  —  pubspec quyết định có mặt", 40, 400, 1520, 320)
    pa = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "composable_auth\nTokenVault", 40, 60, 340, 80, parent=pkgs)
    pl = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "composable_log\nLogQueue", 420, 60, 340, 80, parent=pkgs)
    pp = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "composable_push\nMemoryPushToken", 800, 60, 360, 80, parent=pkgs)
    p.cell(box("#ECEFF1", "#90A4AE", "#546E7A", size=11), "offline / maps / pay\nkhông có trong pubspec", 1200, 60, 260, 80, parent=pkgs)
    p.edge(pa, g4, A_INHERIT, "AuthService implements")
    p.edge(pl, g3, A_IMPORT + A_ORTHO, "LogSink")
    p.edge(pp, g2, A_IMPORT + A_ORTHO, "token; StubPushService → go()")
    p.edge(g2, g4, A_DATA, "redirect")

    tool = p.cell(lane("#CFD8DC", "#607D8B"), "Tooling  —  không import vào app", 40, 750, 1520, 160)
    p.cell(box("#ECEFF1", "#546E7A"), "make init / check / test", 40, 52, 340, 56, parent=tool)
    p.cell(box("#ECEFF1", "#546E7A"), "Fastlane", 420, 52, 340, 56, parent=tool)
    p.cell(box("#ECEFF1", "#546E7A"), "Sheet → ARB", 800, 52, 320, 56, parent=tool)
    p.cell(box("#ECEFF1", "#546E7A"), "Chopper / swagger\nmake api", 1160, 52, 300, 56, parent=tool)
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 06b  Một luồng cắm + dùng cho mọi package
    # ══════════════════════════════════════════════════════════════
    p = Page("p06b", "06b - Auth cắm vào app", 1680, 1000)
    p.cell(title_style(), "Mọi composable package — một luồng cắm, một cách dùng", 40, 16, 1500, 36)
    p.cell(
        legend_style(),
        "serviceXxx(GetIt sl)     sl<XxxService>()     không runApp / không GetIt riêng     OverlayHost không đổi",
        40,
        50,
        1550,
        22,
    )

    plug = p.cell(lane("#E3F2FD", "#1565C0", "#0D47A1"), "1. Cắm  —  giống nhau", 40, 90, 500, 420)
    p1 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "pubspec.yaml\npath dep", 40, 56, 420, 72, parent=plug)
    p2 = p.cell(box("#90CAF9", "#1565C0", "#0D47A1"), "installedPackages\n+= serviceXxx", 40, 160, 420, 72, parent=plug)
    p3 = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "plugPackages(sl)", 40, 264, 420, 72, parent=plug)
    p.edge(p1, p2, A_ACTION, "", parent=plug)
    p.edge(p2, p3, A_ACTION, "", parent=plug)

    use = p.cell(lane("#E8F5E9", "#2E7D32", "#1B5E20"), "2. Dùng  —  singleton GetIt", 580, 90, 520, 420)
    u1 = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "sl<AuthService>()  ==  sl<Session>()", 40, 56, 440, 64, parent=use)
    u2 = p.cell(box("#C8E6C9", "#2E7D32"), "sl<LogService>()", 40, 140, 440, 56, parent=use)
    u3 = p.cell(box("#C8E6C9", "#2E7D32"), "sl<PushService>()  StubPushService", 40, 216, 440, 56, parent=use)
    u4 = p.cell(box("#FFECB3", "#F9A825"), "registerOffline  (chưa cắm)", 40, 292, 440, 56, parent=use)
    p.edge(p3, u1, A_IMPORT, "GetIt")

    miss = p.cell(lane("#FFF8E1", "#F9A825", "#F57F17"), "3. Không có package", 1140, 90, 500, 420)
    m1 = p.cell(box(GOLD, GOLD_S), "xóa 1 dòng +\nxóa pubspec dep", 40, 56, 420, 72, parent=miss)
    m2 = p.cell(box("#FFECB3", "#F9A825"), "ensureCoreServices(sl)\nStubSession · PrintLogSink · StubPushService", 40, 160, 420, 72, parent=miss)
    m3 = p.cell(box("#CFD8DC", "#607D8B", "#37474F"), "OverlayHost\nkhông đụng", 40, 264, 420, 72, parent=miss)
    p.edge(m1, m2, A_ACTION, "", parent=miss)
    p.edge(p3, m2, A_DATA + A_ORTHO, "slot trống")

    inside = p.cell(
        lane("#F3E5F5", "#8E24AA", "#6A1B9A"),
        "Bên trong  —  package chỉ cầm vault/queue/token; app service ghi cửa ngõ core",
        40,
        540,
        1600,
        400,
    )
    s_auth = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "AuthService (app)", 40, 56, 280, 64, parent=inside)
    s_log = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "LogService (app)", 440, 56, 280, 64, parent=inside)
    s_push = p.cell(box("#CE93D8", "#8E24AA", "#FFFFFF"), "StubPushService (core)", 840, 56, 280, 64, parent=inside)
    s_tok = p.cell(box("#E1BEE7", "#8E24AA"), "TokenVault · LogQueue · MemoryPushToken", 1240, 56, 320, 64, parent=inside)
    g_sess = p.cell(circle(RED, RED_S, "#FFFFFF"), "Session", 70, 160, 220, 88, parent=inside)
    g_sink = p.cell(box(LIME, LIME_S), "LogSink", 440, 168, 280, 72, parent=inside)
    g_rt = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "router.go(location)", 840, 168, 280, 72, parent=inside)
    g_core = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "MemoryCacheStore\n+ MemoryOutbox (core)", 1240, 168, 320, 72, parent=inside)
    p.edge(s_auth, g_sess, A_INHERIT, "implements", parent=inside)
    p.edge(s_log, g_sink, A_IMPORT, "enqueue", parent=inside)
    p.edge(s_push, g_rt, A_IMPORT, "open()", parent=inside)
    p.edge(u1, s_auth, A_DATA, "cùng instance")
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 07  Validation + Responsive + Log + Push  (visual, compact)
    # ══════════════════════════════════════════════════════════════
    p = Page("p07", "07 - UI · Log · Push", 1600, 980)
    p.cell(title_style(), "Validation · Responsive · Log · Push", 40, 16, 1000, 36)

    val = p.cell(lane("#E1BEE7", "#8E24AA", "#6A1B9A"), "Validation  (core UI, không package)", 40, 80, 760, 360)
    f = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "AppTextField", 24, 56, 200, 56, parent=val)
    vs = p.cell(box(GOLD, GOLD_S), "required · email\nminLength · all()", 260, 48, 220, 72, parent=val)
    form = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "FormScope\nvalidateAll", 520, 56, 200, 56, parent=val)
    p.edge(f, vs, A_IMPORT, "chạy", parent=val)
    p.edge(form, f, A_ACTION + A_ORTHO, "validateAll", parent=val)

    resp = p.cell(lane("#BBDEFB", "#1565C0", "#0D47A1"), "Responsive  (core UI)", 840, 80, 720, 360)
    bp = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "Breakpoint\ncompact · medium · expanded", 24, 56, 320, 72, parent=resp)
    cl = p.cell(box(GOLD, GOLD_S), "space clamp 0.9–1.15\nfont sàn + textScaler", 372, 56, 324, 72, parent=resp)
    p.edge(bp, cl, A_IMPORT, "áp dụng", parent=resp)
    p.cell(box("#FFCDD2", "#C62828", size=11), "không ScreenUtil .w .h .sp trần", 24, 160, 672, 48, parent=resp)

    log = p.cell(lane("#C8E6C9", "#2E7D32", "#1B5E20"), "Log", 40, 470, 760, 400)
    src = p.cell(box(LIME, LIME_S), "tap · nav · API", 24, 56, 200, 56, parent=log)
    sink = p.cell(box(GREEN, GREEN_S, "#FFFFFF"), "LogSink.add\n(redact, không await)", 260, 56, 220, 56, parent=log)
    q = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "LogQueue → recent", 520, 56, 200, 56, parent=log)
    p.edge(src, sink, A_ACTION, "enqueue", parent=log)
    p.edge(sink, q, A_ACTION, "drain", parent=log)

    push = p.cell(lane("#FFE0B2", "#EF6C00", "#E65100"), "Push  (MemoryPushToken + StubPushService)", 840, 470, 720, 400)
    bg = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "payload map\npath + query", 24, 56, 210, 72, parent=push)
    fg = p.cell(box("#FFB74D", "#EF6C00", "#FFFFFF"), "silent?\n(isSilentPayload)", 256, 56, 210, 72, parent=push)
    tap = p.cell(box(BLUE, BLUE_S, "#FFFFFF"), "StubPushService.open\n→ GoRouter.go", 488, 56, 200, 72, parent=push)
    p.edge(fg, tap, A_ACTION, "không silent", parent=push)
    p.edge(bg, tap, A_ACTION + A_ORTHO, "locationFromPayload", parent=push)
    pages.append(p)

    H_APP = "#2E7D32"
    H_BLU = "#1565C0"
    H_TEAL = "#00695C"
    H_ORG = "#E65100"
    H_RED = "#C62828"
    H_PUR = "#6A1B9A"
    H_GRY = "#455A64"

    # ══════════════════════════════════════════════════════════════
    # 08  Swimlane ngang — request đi qua lớp
    # ══════════════════════════════════════════════════════════════
    HL = (
        "swimlane;horizontal=1;startSize=110;whiteSpace=wrap;html=1;strokeWidth=2;"
        "fontStyle=1;fontSize=14;align=center;verticalAlign=middle;arcSize=4;"
        "fontColor=#FFFFFF;"
    )
    DIA = (
        "rhombus;whiteSpace=wrap;html=1;fontSize=11;fontStyle=1;"
        "align=center;verticalAlign=middle;strokeWidth=2;"
    )
    TERM = (
        "ellipse;whiteSpace=wrap;html=1;fontSize=11;fontStyle=1;"
        "align=center;verticalAlign=middle;strokeWidth=2;"
    )
    APP_B = box("#90CAF9", "#1565C0", "#0D47A1", size=11, sw=2)
    DOM_B = box("#FFCC80", "#EF6C00", "#E65100", size=11, sw=2)
    DAT_B = box("#EF9A9A", "#C62828", "#B71C1C", size=11, sw=2)
    HTTP_B = box("#80CBC4", "#00897B", "#004D40", size=11, sw=2)
    E = A_IMPORT

    p = Page("p08", "08 - Swimlane request", 2160, 1120)
    p.cell(title_style(), "Luồng request — swimlane theo lớp", 40, 12, 1600, 30)
    p.cell(
        legend_style(),
        "Mỗi hàng = một lớp. Hộp cùng màu hàng = thành phần thuộc lớp đó. Hình thoi = quyết định. Mũi tên = tương tác giữa các lớp.",
        40,
        44,
        1800,
        20,
    )

    app_l = p.cell(HL + "fillColor=#1565C0;swimlaneFillColor=#E3F2FD;strokeColor=#0D47A1;", "APP", 40, 80, 2080, 180)
    dom_l = p.cell(HL + "fillColor=#EF6C00;swimlaneFillColor=#FFF3E0;strokeColor=#E65100;", "DOMAIN", 40, 270, 2080, 170)
    data_l = p.cell(HL + "fillColor=#C62828;swimlaneFillColor=#FFEBEE;strokeColor=#B71C1C;", "DATA", 40, 450, 2080, 250)
    http_l = p.cell(HL + "fillColor=#00897B;swimlaneFillColor=#E0F2F1;strokeColor=#00695C;", "HTTP", 40, 710, 2080, 180)

    # APP  (x > startSize 110)
    a0 = p.cell(TERM + "fillColor=#90CAF9;strokeColor=#1565C0;fontColor=#0D47A1;", "Bắt đầu", 130, 52, 90, 70, parent=app_l)
    a1 = p.cell(APP_B, "View\nUser action", 250, 52, 150, 70, parent=app_l)
    a2 = p.cell(APP_B, "OverlayFeedback\npushLoading", 440, 52, 150, 70, parent=app_l)
    a3 = p.cell(APP_B, "BLoC\nEvent", 630, 52, 150, 70, parent=app_l)
    a13 = p.cell(APP_B, "BLoC\nState", 1540, 52, 150, 70, parent=app_l)
    a14 = p.cell(APP_B, "OverlayFeedback\nshowToast", 1730, 52, 150, 70, parent=app_l)
    a15 = p.cell(TERM + "fillColor=#A5D6A7;strokeColor=#2E7D32;fontColor=#1B5E20;", "Xong", 1920, 52, 90, 70, parent=app_l)

    # DOMAIN — Session không nằm trên happy path của Use Case
    d4 = p.cell(DOM_B, "Use Case\nexecute", 630, 48, 150, 70, parent=dom_l)
    d_sess = p.cell(DOM_B, "Session (core)\nUse Case không đọc", 1100, 48, 190, 70, parent=dom_l)
    d12 = p.cell(DOM_B, "Use Case\nResult", 1540, 48, 150, 70, parent=dom_l)

    # DATA — hai nhánh: cache (trên) / network (dưới)
    da5 = p.cell(DAT_B, "Repo Impl\nDataGateway", 630, 40, 150, 64, parent=data_l)
    dia = p.cell(DIA + "fillColor=#FFCDD2;strokeColor=#C62828;fontColor=#B71C1C;", "Cache\nhit?", 830, 70, 130, 100, parent=data_l)
    da_cache = p.cell(DAT_B, "MemoryCacheStore", 1020, 36, 150, 64, parent=data_l)
    da6 = p.cell(DAT_B, "Chopper / DS\nsend", 1020, 150, 150, 64, parent=data_l)
    da10 = p.cell(DAT_B, "SafeDecode", 1540, 150, 150, 64, parent=data_l)
    da11 = p.cell(DAT_B, "Repo Impl\nDTO → Entity", 1540, 36, 160, 64, parent=data_l)

    # HTTP — Interceptor bọc ApiClient, không do Network DS gọi
    h7 = p.cell(HTTP_B, "Interceptor\nAuth · Log · Idempotency", 1020, 48, 200, 80, parent=http_l)
    h8 = p.cell(HTTP_B, "ApiClient\nFake | HTTP", 1280, 48, 140, 80, parent=http_l)
    h9 = p.cell(HTTP_B, "Interceptor\nlog / 401", 1480, 48, 150, 80, parent=http_l)

    p.edge(a0, a1, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(a1, a2, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(a2, a3, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(a3, d4, E, "gọi", parent="1", exit=(0.5, 1), entry=(0.5, 0))
    p.edge(d4, da5, E, "Abstract Repo", parent="1", exit=(0.5, 1), entry=(0.5, 0))
    p.edge(da5, dia, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(dia, da_cache, E, "YES", parent="1", exit=(1, 0.25), entry=(0, 0.5))
    p.edge(dia, da6, E, "NO", parent="1", exit=(1, 0.75), entry=(0, 0.5))
    p.edge(da_cache, da11, E, "trả local", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(da6, h7, E, "client.send\n(bọc sẵn)", parent="1", exit=(0.5, 1), entry=(0.5, 0))
    p.edge(h7, d_sess, E, "authorizationHeaders", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(h7, h8, E, "bọc", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(h8, h9, E, "response", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(h9, da10, E, "", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(da10, da11, E, "", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(da11, d12, E, "", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(d12, a13, E, "Result", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(a13, a14, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(a14, a15, E, "rebuild", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    pages.append(p)

    # ══════════════════════════════════════════════════════════════
    # 09  Swimlane ngang — Session + Router
    # ══════════════════════════════════════════════════════════════
    p = Page("p09", "09 - Swimlane Session + Router", 1960, 920)
    p.cell(title_style(), "Luồng Session + Router — swimlane theo lớp", 40, 12, 1600, 30)
    p.cell(
        legend_style(),
        "GoRouter và Interceptor đọc Session.status / authorizationHeaders. Use Case không có mặt trên luồng này.",
        40,
        44,
        1700,
        20,
    )

    app2 = p.cell(HL + "fillColor=#1565C0;swimlaneFillColor=#E3F2FD;strokeColor=#0D47A1;", "APP", 40, 80, 1880, 180)
    dom2 = p.cell(HL + "fillColor=#EF6C00;swimlaneFillColor=#FFF3E0;strokeColor=#E65100;", "DOMAIN", 40, 270, 1880, 180)
    http2 = p.cell(HL + "fillColor=#00897B;swimlaneFillColor=#E0F2F1;strokeColor=#00695C;", "HTTP", 40, 460, 1880, 200)

    g0 = p.cell(TERM + "fillColor=#90CAF9;strokeColor=#1565C0;fontColor=#0D47A1;", "Deep link\n/ navigate", 130, 50, 110, 76, parent=app2)
    g1 = p.cell(APP_B, "GoRouter\nredirect", 300, 50, 160, 76, parent=app2)
    g2 = p.cell(APP_B, "View\nhiện màn", 1540, 50, 150, 76, parent=app2)
    g3 = p.cell(TERM + "fillColor=#A5D6A7;strokeColor=#2E7D32;fontColor=#1B5E20;", "Xong", 1740, 50, 80, 76, parent=app2)

    s1 = p.cell(DOM_B, "Session\nrestore / status", 300, 50, 180, 76, parent=dom2)
    pol = p.cell(DOM_B, "RoutePolicy\npublic | guest |\nauthRequired", 530, 50, 180, 76, parent=dom2)

    i1 = p.cell(HTTP_B, "Interceptor\nauthorizationHeaders", 880, 40, 190, 70, parent=http2)
    dia401 = p.cell(DIA + "fillColor=#B2DFDB;strokeColor=#00897B;fontColor=#004D40;", "401?\nhandshake?", 1120, 48, 120, 90, parent=http2)
    i2 = p.cell(HTTP_B, "refresh / kick\n(không handshake)", 1300, 40, 190, 70, parent=http2)

    p.edge(g0, g1, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(s1, g1, E, "đọc trạng thái", parent="1", exit=(0.5, 0), entry=(0.5, 1))
    p.edge(pol, g1, E, "đọc policy", parent="1", exit=(0.5, 0), entry=(1, 1))
    p.edge(g1, g2, E, "cho vào / đẩy login", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(g2, g3, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(s1, i1, E, "authorizationHeaders", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(i1, dia401, E, "", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(dia401, i2, E, "YES", parent="1", exit=(1, 0.5), entry=(0, 0.5))
    p.edge(i2, s1, E, "refresh / kick", parent="1", exit=(0.5, 0), entry=(1, 1))
    pages.append(p)

    diagrams = "\n".join(pg.xml() for pg in pages)
    return (
        f'<mxfile host="app.diagrams.net" agent="Cursor" version="22.1.0" pages="{len(pages)}">\n'
        f"{diagrams}\n</mxfile>\n"
    )


def main():
    xml = build()
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(xml)
    print(f"Wrote {OUT} ({len(xml)} bytes)")


if __name__ == "__main__":
    main()
