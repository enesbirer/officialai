import prisma from "../config/prisma";
import { User, Prisma } from "@prisma/client";

export class UserRepository {
  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data, include: { profile: true } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email }, include: { profile: true } });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id }, include: { profile: true } });
  }

  async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { firebaseUid }, include: { profile: true } });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id }, data, include: { profile: true } });
  }
}
