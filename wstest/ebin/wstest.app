{application, wstest,
 [{description, "wstest"},
  {vsn, "0.01"},
  {modules, [
    wstest,
    wstest_app,
    wstest_sup,
    wstest_web,
    wstest_deps
  ]},
  {registered, []},
  {mod, {wstest_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
