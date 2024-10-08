// Note: This file is autogenerated. Do not edit it directly.
//
// Describes the contents of the test directory, which is a blueprint for
// files and directories. Tests can create a unique, safe environment for
// interacting with the contents of such a directory.
//
// Having strong typing for the test directory contents ensures that tests can
// be written with confidence that the files and directories they expect are
// actually found. Otherwise the tests are brittle and can break easily.

import { z } from "zod"

export const MyTestDirectorySchema = z.object({
  name: z.literal("test-environment"),
  type: z.literal("directory"),
  contents: z.object({
    "file.txt": z.object({
      name: z.literal("file.txt"),
      type: z.literal("file"),
      extension: z.literal("txt"),
      stem: z.literal("file."),
    }),
    "initial-file.txt": z.object({
      name: z.literal("initial-file.txt"),
      type: z.literal("file"),
      extension: z.literal("txt"),
      stem: z.literal("initial-file."),
    }),
    "multicursor-file.lua": z.object({
      name: z.literal("multicursor-file.lua"),
      type: z.literal("file"),
      extension: z.literal("lua"),
      stem: z.literal("multicursor-file."),
    }),
    "other-subdirectory": z.object({
      name: z.literal("other-subdirectory"),
      type: z.literal("directory"),
      contents: z.object({
        "other-sub-file.txt": z.object({
          name: z.literal("other-sub-file.txt"),
          type: z.literal("file"),
          extension: z.literal("txt"),
          stem: z.literal("other-sub-file."),
        }),
      }),
    }),
    routes: z.object({
      name: z.literal("routes"),
      type: z.literal("directory"),
      contents: z.object({
        "posts.$postId": z.object({
          name: z.literal("posts.$postId"),
          type: z.literal("directory"),
          contents: z.object({
            "adjacent-file.txt": z.object({
              name: z.literal("adjacent-file.txt"),
              type: z.literal("file"),
              extension: z.literal("txt"),
              stem: z.literal("adjacent-file."),
            }),
            "route.tsx": z.object({
              name: z.literal("route.tsx"),
              type: z.literal("file"),
              extension: z.literal("tsx"),
              stem: z.literal("route."),
            }),
            "should-be-excluded-file.txt": z.object({
              name: z.literal("should-be-excluded-file.txt"),
              type: z.literal("file"),
              extension: z.literal("txt"),
              stem: z.literal("should-be-excluded-file."),
            }),
          }),
        }),
      }),
    }),
    subdirectory: z.object({
      name: z.literal("subdirectory"),
      type: z.literal("directory"),
      contents: z.object({
        "subdirectory-file.txt": z.object({
          name: z.literal("subdirectory-file.txt"),
          type: z.literal("file"),
          extension: z.literal("txt"),
          stem: z.literal("subdirectory-file."),
        }),
      }),
    }),
    "test-setup.lua": z.object({
      name: z.literal("test-setup.lua"),
      type: z.literal("file"),
      extension: z.literal("lua"),
      stem: z.literal("test-setup."),
    }),
  }),
})

export const MyTestDirectoryContentsSchema =
  MyTestDirectorySchema.shape.contents
export type MyTestDirectoryContentsSchemaType = z.infer<
  typeof MyTestDirectorySchema
>

export type MyTestDirectory = MyTestDirectoryContentsSchemaType["contents"]

export const testDirectoryFiles = z.enum([
  "file.txt",
  "initial-file.txt",
  "multicursor-file.lua",
  "other-subdirectory/other-sub-file.txt",
  "other-subdirectory",
  "routes/posts.$postId/adjacent-file.txt",
  "routes/posts.$postId/route.tsx",
  "routes/posts.$postId/should-be-excluded-file.txt",
  "routes/posts.$postId",
  "routes",
  "subdirectory/subdirectory-file.txt",
  "subdirectory",
  "test-setup.lua",
  ".",
])
export type MyTestDirectoryFile = z.infer<typeof testDirectoryFiles>
