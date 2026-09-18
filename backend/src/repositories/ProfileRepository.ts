import prisma from "../config/prisma";
import { Profile, Prisma } from "@prisma/client";

export class ProfileRepository {
  async create(data: Prisma.ProfileCreateInput): Promise<Profile> {
    return prisma.profile.create({ data });
  }

  async findByUserId(userId: string): Promise<Profile | null> {
    return prisma.profile.findUnique({ where: { userId } });
  }

  async update(userId: string, data: Prisma.ProfileUpdateInput): Promise<Profile> {
    return prisma.profile.update({ where: { userId }, data });
  }
}
