// 加载 Fuse.js 和搜索索引，初始化搜索功能
(function () {
    const input = document.getElementById("search-input");
    const results = document.getElementById("search-results");
    if (!input || !results) return;

    let fuse = null;

    // 加载 Fuse.js
    const script = document.createElement("script");
    script.src = "https://cdn.jsdelivr.net/npm/fuse.js@7.1.0/dist/fuse.min.js";
    script.onload = () => {
        // 加载搜索索引
        fetch("/index.json")
            .then((r) => r.json())
            .then((data) => {
                const options = {
                    keys: [
                        { name: "title", weight: 0.4 },
                        { name: "content", weight: 0.3 },
                        { name: "tags", weight: 0.2 },
                        { name: "summary", weight: 0.1 },
                    ],
                    threshold: 0.3,
                    ignoreLocation: true,
                    includeMatches: true,
                    minMatchCharLength: 1,
                };
                fuse = new Fuse(data, options);

                // 如果有缓存的搜索词，立即搜索
                const cached = input.value.trim();
                if (cached) doSearch(cached);
            })
            .catch(() => {
                results.innerHTML =
                    '<p class="search-placeholder">搜索索引加载失败，请稍后重试。</p>';
            });
    };
    document.head.appendChild(script);

    // 监听输入
    let timer;
    input.addEventListener("input", function () {
        clearTimeout(timer);
        const q = this.value.trim();
        if (!q) {
            results.innerHTML = '<p class="search-placeholder">输入关键词开始搜索...</p>';
            return;
        }
        if (!fuse) return;
        timer = setTimeout(() => doSearch(q), 200);
    });

    function doSearch(q) {
        const hits = fuse.search(q);
        if (hits.length === 0) {
            results.innerHTML = '<p class="search-placeholder">没有找到相关文章。</p>';
            return;
        }
        let html = "";
        hits.forEach(({ item, matches }) => {
            // 高亮匹配内容
            let excerpt = item.content || item.summary || "";
            if (excerpt.length > 180) excerpt = excerpt.slice(0, 180) + "...";

            html +=
                '<div class="search-result">' +
                '<h3><a href="' + item.permalink + '">' + item.title + "</a></h3>" +
                '<p class="meta">' + (item.date || "") + "</p>" +
                "<p>" + excerpt + "</p>" +
                "</div>";
        });
        results.innerHTML = html;
    }
})();
