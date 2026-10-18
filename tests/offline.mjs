import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { chromium, expect } from "@playwright/test";

test(
  "downloaded HTML renders art and fonts and plays without a server or network",
  { timeout: 45000 },
  async () => {
    const browser = await chromium.launch({
      executablePath:
        process.env.CHROMIUM_EXECUTABLE_PATH ||
        (existsSync("/usr/bin/chromium") ? "/usr/bin/chromium" : undefined),
      args: ["--no-sandbox", "--disable-dev-shm-usage"],
    });
    const errors = [],
      network = [];
    const context = await browser.newContext({
      offline: true,
      viewport: { width: 1440, height: 1060 },
      reducedMotion: "reduce",
    });
    await context.addInitScript(() => {
      try {
        localStorage.setItem("nexus-v1", JSON.stringify({ reduced: true }));
      } catch {}
    });
    const page = await context.newPage();
    page.on("pageerror", (e) => errors.push(e.message));
    page.on("request", (r) => {
      if (/^https?:/.test(r.url())) network.push(r.url());
    });
    try {
      // This cloud image blocks file: URLs by administrator policy. Test the exact
      // generated document in memory without changing that policy or using a server.
      await page.setContent(
        await readFile(resolve("artifacts/NEXUS-JOGAR.html"), "utf8"),
      );
      await expect(page.locator(".fighter")).toHaveCount(6);
      await page.evaluate(() => document.fonts.ready);
      assert.equal(
        await page.evaluate(
          () =>
            document.fonts.check("12px Cinzel") &&
            document.fonts.check("12px Manrope"),
        ),
        true,
      );
      const atlasSize = await page.evaluate(async () => {
        const image = new Image();
        image.src = globalThis.NEXUS_ASSETS.heroes;
        await image.decode();
        return [image.naturalWidth, image.naturalHeight];
      });
      assert.deepEqual(atlasSize, [1024, 1536]);
      await page.screenshot({
        path: "artifacts/offline-desktop.png",
        fullPage: true,
      });
      await page.locator(".brand").click();
      assert.equal(new URL(page.url()).protocol, "about:");
      await expect(page.locator(".fighter")).toHaveCount(6);
      await page.locator('[data-act="start"]').click();
      await expect(page.locator('[data-act="execute"]')).toBeEnabled();
      await page.locator('[data-act="execute"]').click();
      await expect(page.locator(".log-message.action")).toHaveCount(2, {
        timeout: 15000,
      });
      await expect(page.locator('[data-action="basic"]')).toBeEnabled();
      await page.locator('.nav-link[data-act="roster"]').click();
      await expect(page.locator(".hero-card")).toHaveCount(24);
      await page.keyboard.press("Escape");
      await page.setViewportSize({ width: 390, height: 844 });
      assert.equal(
        await page.evaluate(
          () => document.documentElement.scrollWidth - innerWidth,
        ),
        0,
      );
      await page.screenshot({
        path: "artifacts/offline-mobile.png",
        fullPage: true,
      });
      assert.deepEqual(
        network,
        [],
        "Offline game must not request any HTTP resource",
      );
      assert.deepEqual(
        errors,
        [],
        "Offline game must have no uncaught browser error",
      );
    } finally {
      await context.close();
      await browser.close();
    }
  },
);
