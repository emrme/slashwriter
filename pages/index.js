import { useSession } from 'next-auth/react';
import mongoose from 'mongoose';
import Router from 'next/router';

import Head from 'next/head';
import Image from 'next/image'
import styles from '../styles/Home.module.css'
import Link from 'next/link';

export default function Home() {
    const { data: session } = useSession()
    if (session === undefined) {
        return null
    } else if (session) {
        Router.push("/workspace")
        return null
    }

    return (
        <div className={styles.container}>
            <Head>
                <title>SlashWriter</title>
                <meta name="description" content="Generated by create next app" />
                <link rel="icon" href="/favicon.ico" />
            </Head>

            <main className={styles.main}>
                <h1 className={styles.title}>
                    Welcome to <a href="https://nextjs.org">Next.js!</a>
                </h1>
                <Link href="/auth/signin">Sign In</Link>
            </main>

            <footer className={styles.footer}>
                <a
                    href="https://vercel.com?utm_source=create-next-app&utm_medium=default-template&utm_campaign=create-next-app"
                    target="_blank"
                    rel="noopener noreferrer"
                >
                    Powered by{' '}
                    <span className={styles.logo}>
                        <Image src="/vercel.svg" alt="Vercel Logo" width={72} height={16} />
                    </span>
                </a>
            </footer>
        </div>
    )
}

export async function getServerSideProps(context) {
    const { MONGO_USER, MONGO_PASSWORD, MONGO_CLUSTER, MONGO_DB } = process.env
    mongoose.connect(
        `mongodb+srv://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_CLUSTER}.k3thl.mongodb.net/${MONGO_DB}?retryWrites=true&w=majority`,
        { useNewUrlParser: true, useUnifiedTopology: true }
    )

    return {
        props: {}
    }
}