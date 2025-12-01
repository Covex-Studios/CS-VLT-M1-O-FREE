window.addEventListener("message", (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    const device     = document.getElementById("device");
    const tooltip    = document.getElementById("tooltip");
    const vltNumber  = document.getElementById("vlt-number");
    const vltPercent = document.getElementById("vlt-percent");
    const statusBox  = document.getElementById("status-below");
    const statusText = document.getElementById("status-text");

    if (data.action === "show") {
        device.classList.remove("hidden");
        statusBox.classList.remove("hidden");

        const rawVlt = (typeof data.vlt === "number") ? data.vlt : 0;
        const v = Math.min(Math.max(Math.round(rawVlt), 0), 100);
        vltNumber.textContent = v;

        let color = "#202020ff";

        if (data.code === "legal") {
            color = "#00ff80";
            statusText.textContent = "LEGAL";
        } else if (data.code === "borderline") {
            color = "#ffd700";
            statusText.textContent = "BORDERLINE";
        } else {
            color = "#ff4d6e";
            statusText.textContent = "ILLEGAL";
        }

        vltNumber.style.color  = color;
        vltPercent.style.color = color;
        statusBox.style.borderColor = color;
    }

    if (data.action === "hide") {
        device.classList.add("hidden");
        statusBox.classList.add("hidden");
    }

    if (data.action === "tooltip") {
        tooltip.classList.toggle("hidden", !data.show);
    }
});
