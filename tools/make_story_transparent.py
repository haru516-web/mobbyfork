from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "docs" / "16renai" / "assets" / "story"
OUT_DIR = ROOT / "docs" / "16renai" / "assets" / "story-transparent"
MARK = (1, 2, 3, 255)


def edge_points(width: int, height: int, step: int = 96):
    points = []
    for x in range(0, width, step):
        points.append((x, 0))
        points.append((x, height - 1))
    for y in range(0, height, step):
        points.append((0, y))
        points.append((width - 1, y))
    points.extend([(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)])
    return points


def remove_edge_background(src: Path, dst: Path) -> None:
    image = Image.open(src).convert("RGBA")
    width, height = image.size

    filled = image.copy()
    for point in edge_points(width, height):
        if filled.getpixel(point) != MARK:
            ImageDraw.floodfill(filled, point, MARK, thresh=42)

    data = bytearray(filled.tobytes())
    mark = bytes(MARK)
    for i in range(0, len(data), 4):
        if data[i : i + 4] == mark:
            data[i + 3] = 0

    result = Image.frombytes("RGBA", filled.size, bytes(data))
    bbox = result.getbbox()
    if bbox:
        pad = 32
        left = max(0, bbox[0] - pad)
        top = max(0, bbox[1] - pad)
        right = min(result.width, bbox[2] + pad)
        bottom = min(result.height, bbox[3] + pad)
        result = result.crop((left, top, right, bottom))
    result.save(dst, optimize=True)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    count = 0
    for src in sorted(SRC_DIR.glob("story-*.png")):
        dst = OUT_DIR / src.name
        remove_edge_background(src, dst)
        count += 1
    print(f"processed={count}")


if __name__ == "__main__":
    main()
