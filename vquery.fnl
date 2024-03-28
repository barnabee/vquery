; Simple program to collect multiple pages of Vega data

(local json (require :dkjson))
(local backup-node "https://api.vega.community")

(λ add-query-params [url params]
  (if (= (next params) nil)
      url
      (let [param-strs (icollect [k v (pairs params)] (.. k "=" v))
            query (table.concat param-strs "&")]
        (.. url (if (url:match "^https?://.*/.*%?") "&" "?") query))))

(λ fetch [base-url ?params]
  (let [url (add-query-params base-url (or ?params {}))
        handle (io.popen (.. "curl -s \"" url "\""))]
    (json.decode (handle:read :*a))))

(λ into-page [?x]
  (case ?x
    {: pageInfo} ?x
    x (let [(_ v) ((pairs x) x)] ; assume single JSON key holding entire result
        (tail! (into-page v)))))

(λ print-records [page]
  (each [k v (pairs page)]
    (if (not= k :pageInfo)
        (each [_ record (pairs v)] (-> record.node json.encode print)))))

(λ get-cursor [page]
  (if (?. page :pageInfo :hasNextPage) (?. page :pageInfo :endCursor)))

(λ get-pages [url limit ?cursor ?count]
  (let [resp (fetch url {:pagination.after ?cursor})
        page (into-page resp)
        cursor (get-cursor page)
        count (+ (or ?count 0) 1)]
    (print-records page)
    (if (and cursor (< count limit))
        (tail! (get-pages url limit cursor count)))))

(λ handle-missing-node [url-or-path node-if-missing]
  (if (string.match url-or-path "^https?://")
      url-or-path
      (.. node-if-missing :/api/v2/ url-or-path)))

(let [[url-or-path] arg
      default-node (or (os.getenv :VEGA_DATA_NODE) backup-node)
      url (handle-missing-node url-or-path default-node)
      limit (tonumber (or (os.getenv :VEGA_MAX_PAGES) 10))]
  (get-pages url limit))
